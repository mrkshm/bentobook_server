class DebugController < ApplicationController
  def test_s3
    blob = ActiveStorage::Blob.find(params[:blob_id])

    begin
      # Try to get the content of the file directly
      content = blob.service.download(blob.key)
      render plain: "S3 access successful! File size: #{content.bytesize} bytes"
    rescue => e
      render plain: "S3 access error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}", status: 500
    end
  end
end
