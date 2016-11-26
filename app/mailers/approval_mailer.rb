class ApprovalMailer < ActionMailer::Base

  def mail_to_manager(week, user)
    te = TimeEntry.where("week_id = ? AND user_id = ? and project_id IS NOT NULL", week.id, week.user_id).first
    use = Project.find(te.project_id).user_id
    if !use.nil?
      @manager = User.find(use).email
    else
      @manager = "sameer.sharma@resourcestack.com"
    end
    @week = week
    @sender = user.email

    mail(to: @manager , subject:"Time sheed submitted for approval" , from: @sender )

  end

  def mail_to_user(week, user)
    @user = User.find(week.user_id).email
    @approver = user.email

    @time = week

    mail(to:@user  , subject:"Timesheet Approval" , from:@approver)

  end

  def invitation_accepted(inviter,user)
    @invited_by = User.find(inviter)
    inviter_email = User.find(inviter).email
    @user = user
    user_email = user.email

    mail(to:inviter_email, subject: "Invitation Accepted By #{user_email}", from: user_email)

  end
end