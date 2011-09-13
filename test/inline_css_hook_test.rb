require 'abstract_unit'

TEST_HTML = %Q{
<html>
  <head>
    <style>
      #test { color: #123456; }
    </style>
  </head>
  <body>
    <div id="test">Test</div>
  </body>
</html>}

class HelperMailer < ActionMailer::Base
  helper ActionMailer::InlineCssHelper

  def use_inline_css_hook_with_only_html_part
    mail_with_defaults do |format|
      format.html { render(:inline => TEST_HTML) }
    end
  end

  def use_inline_css_hook_with_text_and_html_parts
    mail_with_defaults do |format|
      format.html { render(:inline => TEST_HTML) }
      format.text { render(:inline => "Different Text Part") }
    end
  end

  protected

  def mail_with_defaults(&block)
    mail(:to => "test@localhost", :from => "tester@example.com",
          :subject => "using helpers", &block)
  end
end


class InlineCssHookTest < ActionMailer::TestCase
  def test_inline_css_hook_with_only_html_part
    mail = HelperMailer.use_inline_css_hook_with_only_html_part.deliver
    assert_match '<div id="test" style="color: #123456;">Test</div>', mail.html_part.body.encoded
    # Test generated text part
    assert_match 'Test', mail.text_part.body.encoded
  end

  def test_inline_css_hook_with_text_and_html_parts
    mail = HelperMailer.use_inline_css_hook_with_text_and_html_parts.deliver
    assert_match '<div id="test" style="color: #123456;">Test</div>', mail.html_part.body.encoded
    # Test specified text part
    assert_match 'Different Text Part', mail.text_part.body.encoded
  end
end

