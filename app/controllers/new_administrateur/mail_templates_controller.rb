module NewAdministrateur
  class MailTemplatesController < AdministrateurController
    include ActionView::Helpers::SanitizeHelper

    def edit
      @procedure = procedure
      @mail_template = find_mail_template_by_slug(params[:id])
    end

    def update
      @procedure = procedure
      mail_template = find_mail_template_by_slug(params[:id])
      mail_template.update(update_params)
      flash.notice = "Email mis à jour"
      redirect_to edit_procedure_mail_template_path(mail_template.procedure_id, params[:id])
    end

    def preview
      @procedure = procedure
      @logo_url = procedure.logo.url
      @service = procedure.service

      mail_template = find_mail_template_by_slug(params[:id])

      render(html: sanitize(mail_template.body), layout: 'mailers/notification')
    end

    private

    def procedure
      @procedure = current_administrateur.procedures.find(params[:procedure_id])
    end

    def mail_templates
      [
        @procedure.initiated_mail_template,
        @procedure.received_mail_template,
        @procedure.closed_mail_template,
        @procedure.refused_mail_template,
        @procedure.without_continuation_mail_template
      ]
    end

    def find_mail_template_by_slug(slug)
      mail_templates.find { |template| template.class.const_get(:SLUG) == slug }
    end

    def update_params
      {
        procedure_id: params[:procedure_id],
        subject: params[:mail_template][:subject],
        rich_body: params[:mail_template][:rich_body]
      }
    end
  end
end
