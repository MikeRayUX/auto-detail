module Orders::LabelCodes
  extend ActiveSupport::Concern
  protected

  def generate_unique_label_code
    @codes = Order.active_labels + CommercialPickup.active_labels

    loop do
      @new_code = SecureRandom.hex(2).upcase
      if codes_unique?(@codes, @new_code)
        return @new_code
        break
      end
    end
  end

  def codes_unique?(codes, new_code)
    codes.length != codes.dup.push(new_code).uniq.length
  end
end
