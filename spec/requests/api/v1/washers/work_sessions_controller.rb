require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/application_statuses_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    DatabaseCleaner.clean_with(:truncation)

    @w = Washer.new(attributes_for(:washer, :activated))
    @w.skip_finalized_washer_attributes = true
    @w.save
    @w.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @w.email)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check success' do
    post '/api/v1/washers/work_sessions',headers: {
      Authorization: 'asdfasdf'
    }
     json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'

    put '/api/v1/washers/work_sessions/1',headers: {
      Authorization: 'asdfasdf'
    }
     json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'

    delete '/api/v1/washers/work_sessions/1',headers: {
      Authorization: 'asdfasdf'
    }
     json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  # CREATE START
  scenario 'washer has no current sessions so one is created' do
    post '/api/v1/washers/work_sessions',headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 201
    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'session_created'

    expect(@w.work_sessions.count).to eq 1

    # WorkSession
    @session = @w.work_sessions.last

    expect(@session.last_checked_in_at).to be_present
    expect(@session.secure_id).to be_present
    expect(json['session_id']).to eq @session.secure_id
  end

  scenario 'washer has no current sessions but is also deactivated so a session expired message is returned' do
    @w.update(attributes_for(:washer, :deactivated))

    post '/api/v1/washers/work_sessions',headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'not_activated'

    # washer
    @w.reload
    expect(@w.work_sessions.count).to eq 0
    expect(@w.last_online_at).to eq nil
  end

  scenario 'washer goes online but there is already refreshable work_session thats in progress so the existing session is terminated and a new session is created' do
    @refreshable_session = @w.work_sessions.create!(attributes_for(:work_session, :refreshable))

    expect(@refreshable_session.refreshable?).to eq true

    post '/api/v1/washers/work_sessions',
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 201
    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'session_created'

    expect(@w.work_sessions.count).to eq 2
    # New WorkSession
    @session = @w.work_sessions.last
    expect(@session.last_checked_in_at).to be_present
    expect(@session.secure_id).to be_present
    expect(json['session_id']).to eq @session.secure_id

    # Stale WorkSession
    @refreshable_session.reload
    expect(@refreshable_session.terminated_at).to be_present

    # Washer
    @w.reload
    expect(@w.last_online_at).to be_present
    expect(@w.is_online?).to eq true 
  end

  scenario 'washer is offline and sessions are stale so they are killed and washer is now online' do
    travel_to(DateTime.current - (WorkSession::REFRESH_LIMIT + 1).minutes) do
      @refreshable_session = @w.work_sessions.create!(attributes_for(:work_session, :refreshable))
      expect(@refreshable_session.refreshable?).to eq true
      @w.refresh_online_status
    end

    @w.reload
    expect(@w.is_online?).to eq false

    post '/api/v1/washers/work_sessions',
    headers: {
      Authorization: @auth_token
    }

    # Washer
    @w.reload
    expect(@w.is_online?).to eq true
    expect(Washer.online.count).to eq 1
  end

  scenario 'washer has many stale sessions and all of them are terminated' do
    @num = rand(50..101)

    @num.times do
      @w.work_sessions.create!(attributes_for(:work_session, :refreshable))
    end

    expect(@w.work_sessions.count).to eq @num

    @w.work_sessions.all.each do |s|
      expect(s.refreshable?).to eq true
    end

    post '/api/v1/washers/work_sessions', 
    headers: {
      Authorization: @auth_token
    }
    json = JSON.parse(response.body)

    expect(json['code']).to eq 201
    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'session_created'

    expect(@w.work_sessions.terminated.count).to eq @num
    expect(@w.work_sessions.count).to eq @num + 1
    
    # New WorkSession
    @session = @w.work_sessions.last
    expect(@session.last_checked_in_at).to be_present
    expect(@session.secure_id).to be_present
    expect(json['session_id']).to eq @session.secure_id
  end
  # CREATE END

  # PUT START
  scenario 'washers session is refreshed within the session refresh deadline' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :refreshable))

    put '/api/v1/washers/work_sessions/1', { 
      params: {
        work_session: {
          secure_id: @session.secure_id
        }
      },
      headers: {
        Authorization: @auth_token
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 204
    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'session_refreshed'
    expect(json['session_id']).to eq @session.secure_id

    # Washer
    @w.reload
    expect(@w.last_online_at).to be_present
    expect(@w.is_online?).to eq true
  end

  scenario 'washers session has expired and is not refreshable so the session is terminated instead' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :stale))
    @w.update(attributes_for(:washer, :offline))

    put '/api/v1/washers/work_sessions/1', { 
      params: {
        work_session: {
          secure_id: @session.secure_id
        }
      },
      headers: {
        Authorization: @auth_token
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'session_terminated'
    expect(json['errors']).to eq 'Session Expired.'

    @session.reload
    expect(@session.terminated_at).to be_present
    expect(json['session_id']).to eq @session.secure_id

    # Washer
    @w.reload
    expect(@w.last_online_at).to eq nil
    expect(@w.is_offline?).to eq true
  end

  scenario 'washers session has expired and is not refreshable via time travel' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :refreshable))
    @w.refresh_online_status

    travel_to(DateTime.current + (WorkSession::REFRESH_LIMIT + 1).minutes) do
      put '/api/v1/washers/work_sessions/1', { 
        params: {
          work_session: {
            secure_id: @session.secure_id
          }
        },
        headers: {
          Authorization: @auth_token
        }
      }
    end

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'session_terminated'
    expect(json['errors']).to eq 'Session Expired.'

    @session.reload
    expect(@session.terminated_at).to be_present
    expect(json['session_id']).to eq @session.secure_id

    # Washer
    @w.reload
    expect(@w.last_online_at).to eq nil
    expect(@w.is_offline?).to eq true
  end

  scenario 'washer is deactivated so not_activated message is returned' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :refreshable))
    @w.deactivate!
    @w.refresh_online_status

    put '/api/v1/washers/work_sessions/1', { 
      params: {
        work_session: {
          secure_id: @session.secure_id
        }
      },
      headers: {
        Authorization: @auth_token
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'not_activated'

    # Washer
    @w.reload
    expect(@w.last_online_at).to eq nil
    expect(@w.is_offline?).to eq true
  end

  scenario 'invalid session secure_id is passed and a session_expired error is returned' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :stale))
    @w.refresh_online_status

    put '/api/v1/washers/work_sessions/1', { 
      params: {
        work_session: {
          secure_id: 'asdfasdfasdf'
        }
      },
      headers: {
        Authorization: @auth_token
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'session_expired'
    expect(json['errors']).to eq 'Your session has expired. Please enable Go Online again.'

    # Washer
    @w.reload
    expect(@w.last_online_at).to eq nil
    expect(@w.is_offline?).to eq true
  end
  # PUT END

  # DESTROY START
  scenario 'washers session is terminated successfully' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :refreshable))
    @w.refresh_online_status

    delete '/api/v1/washers/work_sessions/1', { 
      params: {
        work_session: {
          secure_id: @session.secure_id
        }
      },
      headers: {
        Authorization: @auth_token
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 204
    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'session_terminated'

    @session.reload
    expect(@session.terminated?).to eq true
    expect(json['session_id']).to eq @session.secure_id

    # Washer
    @w.reload
    expect(@w.last_online_at).to eq nil
    expect(@w.is_offline?).to eq true
  end

  scenario 'session was already terminated so session_already_terminated message is returned' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :refreshable))
    @session.terminate!
    @w.go_offline

    delete '/api/v1/washers/work_sessions/1', { 
      params: {
        work_session: {
          secure_id: @session.secure_id
        }
      },
      headers: {
        Authorization: @auth_token
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 204
    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'session_already_terminated'

    # Washer
    @w.reload
    expect(@w.last_online_at).to eq nil
    expect(@w.is_offline?).to eq true
  end

  scenario 'invalid session secure_id is passed and a session_expired error is returned' do
    @session = @w.work_sessions.create!(attributes_for(:work_session, :stale))

    delete '/api/v1/washers/work_sessions/1', { 
      params: {
        work_session: {
          secure_id: 'asdfasdfasdf'
        }
      },
      headers: {
        Authorization: @auth_token
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'session_expired'
    expect(json['errors']).to eq 'Your session has expired. Please enable Go Online again.'

    # Washer
    @w.reload
    expect(@w.last_online_at).to eq nil
    expect(@w.is_offline?).to eq true
  end
  # DESTROY END
end