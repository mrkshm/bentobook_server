# Hotwire Native Navigation Patterns

## Breaking Out of Turbo Frames in Hotwire Native

When working with Hotwire Native apps, especially with bottom sheet modals, we need special handling to properly navigate after form submissions. This document outlines the pattern we discovered for handling navigation from bottom sheets in Hotwire Native.

### The Problem

In Hotwire Native, bottom sheets are triggered on routes named "edit". When submitting a form from within a bottom sheet, we need to:

1. Close the bottom sheet
2. Navigate to a new page

Standard redirects and Turbo Frame targeting don't work reliably in this context.

### Solution: Custom Turbo Stream Actions

We implemented a solution using custom Turbo Stream actions to handle navigation properly:

#### 1. Define a Custom Turbo Stream Action in JavaScript

```javascript
// app/javascript/application.js
Turbo.StreamActions.visit = function() {
  Turbo.visit(this.getAttribute("location"))
}
```

#### 2. Create a Custom Turbo Stream Template

```erb
<!-- app/views/your_controller/update.turbo_stream.erb -->
<%= turbo_stream_action_tag "visit", location: your_path %>
```

#### 3. Update the Controller to Use the Template

```ruby
def update
  if @record.update(record_params)
    respond_to do |format|
      format.html do
        redirect_to record_path(@record)
      end
      format.turbo_stream do
        if hotwire_native_app?
          # For Hotwire Native, use custom template to break out of the frame
          render template: "your_controller/update"
        else
          # For web, replace the partial
          render turbo_stream: turbo_stream.replace(
            dom_id(@record),
            partial: "your_controller/display",
            locals: { record: @record }
          )
        end
      end
    end
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### 4. Update the Form to Request Turbo Stream Format

```erb
<%= button_to "Submit",
            record_path(record_id: @record.id, format: :turbo_stream),
            method: :patch,
            params: { record: params },
            class: "button",
            form: { class: "inline" } %>
```

### How It Works

1. The form submits a PATCH request with `format: :turbo_stream`
2. The controller detects Hotwire Native and renders the custom turbo_stream template
3. The template uses the custom `visit` Turbo Stream action
4. The JavaScript executes `Turbo.visit` with the target path
5. This properly closes the bottom sheet and navigates to the destination page

### Alternative Approaches (Not Recommended)

1. **Using data attributes**: Adding `data: { turbo_frame: "_top", turbo_action: "replace" }` to forms and links. This approach is less reliable.

2. **Using success_url parameter**: Passing a success_url parameter to the controller and redirecting to it. This works for HTML responses but not for Turbo Stream responses.

### When to Use This Pattern

Use this pattern when:

1. You have a form inside a Hotwire Native bottom sheet modal
2. You need to navigate to a different page after form submission
3. Standard redirects or Turbo Frame targeting isn't working

### Example Implementation

See the Cuisine Selections controller and views for a complete implementation example:

- `app/controllers/restaurants/cuisine_selections_controller.rb`
- `app/views/restaurants/cuisine_selections/update.turbo_stream.erb`
- `app/views/restaurants/cuisine_selections/_types.html.erb`
