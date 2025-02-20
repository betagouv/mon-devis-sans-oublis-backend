# frozen_string_literal: true

# Add feedbacks for us only like customer support.
module QuoteCheckFeedbacks
  extend ActiveSupport::Concern

  included do
    has_many :feedbacks, class_name: "QuoteCheckFeedback", dependent: :destroy
  end
end
