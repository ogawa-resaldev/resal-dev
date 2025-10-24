module V1
  class Root < Grape::API
    helpers V1::Helpers::ApplicantHelper
    helpers V1::Helpers::LineTemplateHelper
    helpers V1::Helpers::MailTemplateHelper
    helpers V1::Helpers::ReservationHelper
    helpers V1::Helpers::ReviewHelper
    helpers V1::Helpers::TherapistHelper

    prefix 'api'
    version 'v1', using: :path
    format :json
    content_type :json, 'application/json;charset=UTF-8'

    mount V1::Applicants
    mount V1::LineTemplates
    mount V1::MailTemplates
    mount V1::Reservations
    mount V1::Reviews
  end
end
