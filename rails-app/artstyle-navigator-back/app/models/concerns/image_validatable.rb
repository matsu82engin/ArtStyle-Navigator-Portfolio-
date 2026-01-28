module ImageValidatable
  extend ActiveSupport::Concern

  included do
    validate :validate_attached_image
  end

  private

  def validate_attached_image
    return unless image_attached?

    valid_types = %w[image/png image/jpg image/jpeg]
    errors.add(attached_image_name, 'はPNGまたはJPEG形式でアップロードしてください') unless attached_image.content_type.in?(valid_types)
    errors.add(attached_image_name, 'は5MB以下にしてください') if attached_image.byte_size > 5.megabytes
  end

  def attached_image
    raise NotImplementedError
  end

  def image_attached?
    attached_image.attached?
  end

  def attached_image_name
    :image
  end
end
