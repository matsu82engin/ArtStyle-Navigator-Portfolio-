module SeedUtils
  module MimeTypeHelper
    # 拡張子の対応
    def self.mime_type_from(ext)
      case ext
      when '.jpg', '.jpeg'
        'image/jpeg'
      when '.png'
        'image/png'
      else
        raise "未対応の拡張子です: #{ext}"
      end
    end
  end
end
