# Real-Time Field Validation in Flutter Forms

## The Solution: AutovalidateMode

Flutter provides `AutovalidateMode` to control when validation occurs.

## Three Validation Modes

### 1. **AutovalidateMode.disabled** (Default)
**When**: Only validates when you call `form.validate()`  
**Use case**: Don't want to show errors until user submits

```dart
Form(
  autovalidateMode: AutovalidateMode.disabled,
  // Validates only on submit button press
)
```

### 2. **AutovalidateMode.always**
**When**: Validates immediately and on every change  
**Use case**: Show errors from the start (usually annoying for users)

```dart
Form(
  autovalidateMode: AutovalidateMode.always,
  // Shows "Email is required" even on empty form
)
```

### 3. **AutovalidateMode.onUserInteraction** ✅ (Best)
**When**: Validates after user interacts with field  
**Use case**: Smart validation - only after user touches the field

```dart
Form(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  // Validates field after user starts typing or leaves it
)
```

## Implementation: Smart Validation Pattern

### Pattern: Disabled → OnUserInteraction

Start with validation disabled, enable after first submit attempt:

```dart
class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode, // ← Dynamic mode
      child: Column(
        children: [
          TextFormField(
            validator: ValidationRules.validateEmail,
            // Will validate based on current autovalidateMode
          ),
          ElevatedButton(
            onPressed: () {
              // Enable real-time validation after first attempt
              setState(() {
                _autovalidateMode = AutovalidateMode.onUserInteraction;
              });
              
              if (_formKey.currentState!.validate()) {
                // Submit form
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## User Experience Flow

### Initial State (Disabled)
```
User opens form
↓
No validation errors shown
↓
Form looks clean and inviting
```

### After First Submit Attempt
```
User clicks submit with invalid data
↓
autovalidateMode = onUserInteraction
↓
All fields show errors
↓
User starts fixing fields
↓
Each field validates as user types
↓
Error disappears when valid
```

## Alternative: Per-Field Validation

Want different behavior per field? Use individual `TextFormField` controllers:

```dart
class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _validateUsername = false;
  bool _validateEmail = false;

  @override
  void initState() {
    super.initState();
    
    // Validate username after user stops typing for 500ms
    _usernameController.addListener(() {
      if (_usernameController.text.isNotEmpty) {
        setState(() => _validateUsername = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            validator: _validateUsername 
                ? ValidationRules.validateUsername 
                : null, // Don't validate until triggered
          ),
          TextFormField(
            controller: _emailController,
            validator: _validateEmail
                ? ValidationRules.validateEmail
                : null,
            onEditingComplete: () {
              // Validate when user presses "next" or "done"
              setState(() => _validateEmail = true);
            },
          ),
        ],
      ),
    );
  }
}
```

## Advanced: Debounced Validation

Validate after user stops typing (better for expensive operations):

```dart
import 'dart:async';

class _RegisterFormState extends State<RegisterForm> {
  Timer? _debounce;
  final _formKey = GlobalKey<FormState>();

  void _onUsernameChanged(String value) {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Start new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Validate only this field after 500ms of no typing
      _formKey.currentState?.validate();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        onChanged: _onUsernameChanged,
        validator: ValidationRules.validateUsername,
      ),
    );
  }
}
```

## Validation Strategies Comparison

| Strategy | When Validates | UX | Use Case |
|----------|---------------|-----|----------|
| **Disabled** | Only on submit | Clean initial form | Simple forms |
| **Always** | Immediately | Annoying errors | Don't use |
| **OnUserInteraction** | After user touches field | Smart feedback | ✅ Best for most cases |
| **Disabled → OnUserInteraction** | After first submit | Best of both | ✅ Recommended |
| **Debounced** | After typing stops | Smooth, no lag | Expensive validation |

## Complete Example: Best Practice

```dart
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Start with validation disabled
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Enable real-time validation
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });
    
    // Validate all fields
    if (_formKey.currentState!.validate()) {
      // All fields valid - submit form
      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      
      // Dispatch to BLoC or call API
      context.read<AuthBloc>().add(
        RegisterSubmitted(
          username: username,
          email: email,
          password: password,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode, // Dynamic mode
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
            validator: ValidationRules.validateUsername,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: ValidationRules.validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            validator: ValidationRules.validatePassword,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(), // Submit on "done"
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
```

## Visual Feedback: Error States

Enhance UX with visual feedback:

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    // Show icon based on validation
    suffixIcon: _emailIsValid
        ? Icon(Icons.check_circle, color: Colors.green)
        : null,
    // Change border color
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _emailIsValid ? Colors.green : Colors.grey,
      ),
    ),
  ),
  validator: (value) {
    final error = ValidationRules.validateEmail(value);
    setState(() => _emailIsValid = error == null);
    return error;
  },
)
```

## Summary: Your Implementation ✅

You now have:

```dart
// 1. Start with validation disabled
AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

// 2. Apply to form
Form(
  autovalidateMode: _autovalidateMode,
  ...
)

// 3. Enable on first submit attempt
onPressed: () {
  setState(() {
    _autovalidateMode = AutovalidateMode.onUserInteraction;
  });
  if (_formKey.currentState!.validate()) {
    // Submit
  }
}
```

**Result**:
- ✅ Clean initial form (no errors)
- ✅ Shows errors after first submit
- ✅ Real-time validation as user fixes issues
- ✅ Each field validates independently
- ✅ Best user experience

Perfect implementation! 🎉
