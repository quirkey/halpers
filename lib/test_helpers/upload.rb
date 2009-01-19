module UploadTestHelper
  
  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
  
  def public_file_on_fs(file_path)
    File.join(Rails.root,'public',file_path)
  end

  def assert_public_file_is_readable(file_path)
    assert File.readable?(public_file_on_fs(file_path)), "#{file_path} is not readable or does not exist"
  end

  def assert_public_file_is_not_readable(file_path)
    assert !File.readable?(public_file_on_fs(file_path)), "#{file_path} is readable but it shouldnt be"
  end

  def uploaded_pdf
    uploaded_file(uploaded_pdf_path,'application/pdf')
  end

  def uploaded_jpg(filename = 'test.jpg')
    uploaded_file(uploaded_jpg_path(filename),'image/jpeg')
  end

  def uploaded_asset_path(filename)
    File.expand_path(File.join(__FILE__,'..','..','assets',filename))
  end

  def uploaded_pdf_path
    uploaded_asset_path('test.pdf')
  end

  def uploaded_jpg_path(filename = 'test.jpg')
    uploaded_asset_path(filename)
  end
end