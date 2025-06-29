class ErrorsController < ApplicationController
  # Skip CSRF token for error pages (errors may occur before session is established)
  skip_before_action :verify_authenticity_token

  VALID_STATUS_CODES = %w[400 404 406 422 500].freeze

  # Map status codes to human-readable messages
  ERROR_MESSAGES = {
    '400' => 'Bad Request',
    '404' => 'Page Not Found',
    '406' => 'Not Acceptable',
    '422' => 'Unprocessable Entity',
    '500' => 'Internal Server Error'
  }.freeze

  def error_page
    @status_code = VALID_STATUS_CODES.include?(params[:code]) ? params[:code] : "500"
    @error_message = ERROR_MESSAGES[@status_code]

    respond_to do |format|
      format.html { render "error_page", status: @status_code.to_i }
      format.any  { head @status_code.to_i }
    end
  end
end
