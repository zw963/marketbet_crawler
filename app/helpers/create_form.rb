class App < Roda
  def create_form(
    class_name,
    placeholder:,
    action: request.path,
    method: 'get',
    icon: "search",
    param: 'q',
    grid_offset: nil,
    onclick: "this.closest('form').submit(); return false;"
  )
<<-HEREDOC
<form action="#{action}" autocomplete="on" method="#{method}">
  <div class="input-field col s4 #{grid_offset}">
    <input type="text" name="#{param}" id="autocomplete-input" class="#{class_name}" value="#{request.params[param]}" aria-label="Search">
    <i class="material-icons prefix submit-icon" onclick="#{onclick}">#{icon}</i>
    <label for="autocomplete-input">#{placeholder}</label>
  </div>
</form>
HEREDOC
  end
end
