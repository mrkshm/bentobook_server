class DebugController < ApplicationController
  def test_s3
    begin
      # Try to find the blob first
      blob = ActiveStorage::Blob.find_by!(key: params[:blob_id])

      # Try to get the content of the file directly
      content = blob.service.download(blob.key)
      render plain: "S3 access successful! File size: #{content.bytesize} bytes"
    rescue ActiveRecord::RecordNotFound => e
      render plain: "Blob not found with key: #{params[:blob_id]}", status: 404
    rescue => e
      render plain: "S3 access error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}", status: 500
    end
  end
end
