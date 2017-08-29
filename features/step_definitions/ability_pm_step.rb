
Given(/^I am a project manager$/) do
  create_project_manager
end

Given(/^PM logs in with "([^"]*)" and "([^"]*)"$/) do |email, password|
  # save_and_open_page
  visit (user_session_path)
  page.fill_in "Email", :with => "pm.user@test.com"
  page.fill_in "Password", :with => "123456"
  page.click_button "Log in"
end

Given(/^On the index page$/) do
  visit (weeks_path)
end

Then(/^Expect page to have "([^"]*)" link$/) do |arg1|
  expect(page).to have_link(arg1)
end


Then(/^Expect page to have link "([^"]*)" and "([^"]*)"$/) do |arg1, arg2|
  page.should have_button('Save Timesheet')
  page.should have_button('Submit Timesheet')
end

Then(/^I should see link to "([^"]*)" and "([^"]*)"$/) do |arg1, arg2|
  # save_and_open_page
  expect(page).to have_link(arg1, href: '/weeks/new')
  expect(page).to have_link(arg2, href: 'projects')
end

Then(/^when user goes to projects reports page$/) do
  visit ('/show_project_reports?id=1')
end

Given(/^he should see Time Sheets Submitted for Approval$/) do
 # visit ('/projects')
 expect(page).to have_content("Time Entries")
end

Then(/^he should see "([^"]*)"$/) do |project_report_heading|
  # save_and_open_page
  expect(page).to have_content(project_report_heading)
end

Then(/^User should see "([^"]*)" button$/) do |arg1|
  # save_and_open_page
  expect(page).to have_link(arg1, href: 'projects/1/approve/1/0')
end

Then(/^Go to the index page$/) do
  visit (weeks_path)
end

Given(/^User is on Weeks index$/) do
  visit (weeks_path)
end

Given(/^click on the "([^"]*)"$/) do |projects_link|
  # save_and_open_page
  page.click_link projects_link
end



Then(/^Should see "([^"]*)" and link to the project$/) do |listing_projects|
  page.should have_content(listing_projects)
  expect(page).to have_link('Manage', href: '/projects/1/edit')
end

Then(/^User should see "([^"]*)"$/) do |arg1|
  expect(page).to have_content(arg1)
end

Then(/^User clicks on "([^"]*)" link$/) do |destroy_link|
  visit (projects_path)
  page.click_link destroy_link
end


Then(/^click the project link$/) do
  page.click_link('Manage')
end

Then(/^Text "([^"]*)" should be present$/) do |editing_project|
  # save_and_open_page
  page.should have_content(editing_project)
end

Then(/^Should be abel to visit tasks page$/) do
  visit (tasks_path)
end

And(/^Select "([^"]*)" from "([^"]*)"$/) do |arg1, arg2|
 #click_on(class: "project_id")
 # find('#week_time_entries_attributes_0_project_id').find(:xpath, 'option[1]').select_option
 select("Time Entries", from: "week_time_entries_attributes_0_project_id").select_option
end

Then(/^Click on the "([^"]*)" button for a particular task$/) do |edit_link|
  # save_and_open_page
  expect(page).to have_link(edit_link, href: '/tasks/1/edit')
  page.click_link edit_link
end

Then(/^Should see "([^"]*)" and "([^"]*)"$/) do |task_edit_heading, task_description|
  # save_and_open_page
  page.should have_content(task_edit_heading)
  expect(find_field('Description').value).to eq task_description
end

Then(/^Click on link "([^"]*)"$/) do |arg1|
  # save_and_open_page
  expect(page).to have_link("Add Task")
  find('#tasklist').find('a[href$="#"]').click
  sleep 5
end

Then(/^Fill the code and description of the task$/) do
  # save_and_open_page
  # page.click_link("Add Task")
  # expect(page).to have_css('task-code')
end


Then(/^User should see label "([^"]*)"$/) do |arg1|
  page.should have_content(arg1) # Write code here that turns the phrase above into concrete actions
end

Then(/^click on the "([^"]*)" button$/) do |arg1|
 page.click_link("Vacation Request")
end

Then(/^select a "([^"]*)"$/) do |arg1|
 
end

Then(/^Expect page to have "([^"]*)"$/) do |arg1|
  expect(page).to have_link(arg1)
end


