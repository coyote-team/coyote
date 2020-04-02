# frozen_string_literal: true

require "nokogiri"

module Coyote
  module Testing
    # Methods to facilitate testing email content
    module EmailHelpers
      # Parse an email body into a Nokogiri object that can be tested
      # @param email [Email::Message] the email message with a body to parse
      # @return [Nokogiri::HTML::Document] the email body as an HTML document that can be queried
      def email_to_dom(email)
        email_body = email.body.to_s
        Nokogiri::HTML(email_body)
      end

      # Extract a URL from the body of an email
      # @param email [Email::Message] the email message with a body to parse
      # @return [Nokogiri::HTML::Document] the email body as an HTML document that can be queried
      # @param path [String] an XPath query; defaults to //a/@href, which will return the first anchor tag with an href attribute
      # @return [String] the URL extracted from the email body
      def extract_email_link(email, path = "//a/@href")
        email_to_dom(email).at_xpath(path).value
      end
    end
  end
end
