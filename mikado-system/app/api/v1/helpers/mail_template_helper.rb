module V1
  module Helpers
    module MailTemplateHelper
      def createApplicantMail(subject, body, mailParams)
        mail_template = {
          subject: subject,
          body: body
        }

        mailParams.each do |(key, param)|
          case key
          when "applicantName"
            mail_template[:subject].gsub!("{{applicant_name}}",param)
            mail_template[:body].gsub!("{{applicant_name}}",param)
          when "interviewDatetime"
            mail_template[:subject].gsub!("{{interview_datetime}}",param)
            mail_template[:body].gsub!("{{interview_datetime}}",param)
          when "interviewerName"
            mail_template[:subject].gsub!("{{interviewer_name}}",param)
            mail_template[:body].gsub!("{{interviewer_name}}",param)
          when "passClassificationName"
            mail_template[:subject].gsub!("{{pass_classification_name}}",param)
            mail_template[:body].gsub!("{{pass_classification_name}}",param)
          when "passClassificationFees"
            passClassificationFees = ""
            passClassificationSumAmount = 0
            mailParams["passClassificationFees"].each do |passClassificationFee|
              passClassificationFees = passClassificationFees + passClassificationFee["fee_name"] + "　￥" + passClassificationFee["amount"].to_i.to_formatted_s(:delimited)
              if passClassificationFee["annotation"] != "" then
                passClassificationFees = passClassificationFees + " " + passClassificationFee["annotation"]
              end
              passClassificationFees = passClassificationFees + "\r\n"
              passClassificationSumAmount = passClassificationSumAmount + passClassificationFee["amount"].to_i
            end
            mail_template[:subject].gsub!("{{pass_classification_fees}}",passClassificationFees)
            mail_template[:body].gsub!("{{pass_classification_fees}}",passClassificationFees)
            mail_template[:subject].gsub!("{{pass_classification_sum_amount}}", passClassificationSumAmount.to_formatted_s(:delimited))
            mail_template[:body].gsub!("{{pass_classification_sum_amount}}", passClassificationSumAmount.to_formatted_s(:delimited))
          when "professionalName"
            mail_template[:subject].gsub!("{{professional_name}}",param)
            mail_template[:body].gsub!("{{professional_name}}",param)
          when "senderName"
            mail_template[:subject].gsub!("{{sender_name}}",param)
            mail_template[:body].gsub!("{{sender_name}}",param)
          end
        end

        mail_template
      end
    end
  end
end
