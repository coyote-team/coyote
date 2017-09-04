module Coyote
  # Place where we temporarily store ID number to status mapping before making this part of the database
  # @see https://github.com/coyote-team/coyote/issues/112
  module Statuses
    READY_TO_REVIEW = 1
    APPROVED = 2
    NOT_APPROVED = 3
  end
end
