module V1
  module Helpers
    module LineTemplateHelper
      def createApplicantLine(body, lineParams)
        line_template = body

        lineParams.each do |(key, param)|
          case key
          when "applicantName"
            line_template.gsub!("{{applicant_name}}",param)
          when "interviewDatetime"
            line_template.gsub!("{{interview_datetime}}",param)
          when "interviewerName"
            line_template.gsub!("{{interviewer_name}}",param)
          when "professionalName"
            line_template.gsub!("{{professional_name}}",param)
          when "senderName"
            line_template.gsub!("{{sender_name}}",param)
          end
        end

        line_template
      end
    end
  end
end
