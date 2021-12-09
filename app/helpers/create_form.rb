class App < Roda
  def create_form(
    class_name,
    placeholder:,
    action: request.path,
    method: 'get',
    icon: "search",
    param: 'q',
    grid_offset: nil,
    onclick: "this.closest('form').submit(); return false;",
    autocomplete: "on",
    size: 2,
    use_input: true
  )

    str1 = <<~HEREDOC
      <form action="#{action}" autocomplete="#{autocomplete}" method="#{method}">
        <div class="input-field col s#{size} #{grid_offset}">
    HEREDOC

    str2 = <<~HEREDOC
          <i class="material-icons prefix submit-icon" onclick="#{onclick}">#{icon}</i>
          <label for="autocomplete-input">#{placeholder}</label>
        </div>
      </form>
    HEREDOC

    input = <<-HEREDOC if use_input
    <input type="text" name="#{param}" id="autocomplete-input" class="#{class_name}" value="#{request.params[param]}" aria-label="Search">
HEREDOC

    str1 + input.to_s + str2
  end
end
