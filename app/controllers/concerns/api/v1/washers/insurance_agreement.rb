module Api::V1::Washers::InsuranceAgreement 
  extend ActiveSupport::Concern

  INSURANCE_AGREEMENT = {
    heading: 'Insurance Agreement',
    blocks: [
      {
        id: 0,
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum interdum augue vitae lacus vehicula fringilla. Praesent ut felis urna. Aliquam lacinia dignissim tortor, eu interdum libero tincidunt a. Curabitur ut metus lobortis, vehicula metus nec, finibus augue. Cras gravida, lorem ac commodo vulputate, erat lacus rutrum magna, vitae pulvinar ipsum tellus a lacus. Vivamus iaculis ipsum sagittis, feugiat mi at, ultricies quam. Morbi fermentum, purus sed consectetur ornare, sem nisl malesuada dolor, et gravida odio velit vel nisi. Sed venenatis augue consectetur augue interdum consequat. Pellentesque nunc risus, pulvinar et est nec, interdum ultrices purus. Praesent accumsan arcu nec tempor aliquet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sed venenatis odio. Praesent blandit lorem ac urna ultrices, a sollicitudin tortor consectetur. Fusce quis elit turpis. Morbi consequat auctor orci.'
      },
    ]
  }
end
