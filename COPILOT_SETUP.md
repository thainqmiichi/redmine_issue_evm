# GitHub Copilot Setup for Redmine EVM Plugin

This guide explains how to use GitHub Copilot for automated code review in the Redmine EVM Plugin.

## 🎯 **Plugin-Specific Configuration**

The Copilot configuration is located in `.copilot/` directory within the plugin folder:

```
plugins/redmine_issue_evm/
├── .copilot/
│   ├── settings.json          # Main configuration
│   ├── templates/
│   │   └── review.md          # Review template
│   └── prompts/
│       ├── review_prompt.md   # General review prompt
│       └── security_review.md # Security review prompt
```

## 🚀 **How It Works**

### **Automated Review Process**
1. **Push Code** → GitHub Actions triggers
2. **Plugin Analysis** → Tests, RuboCop, Security scan
3. **Copilot Review** → Generates Redmine-specific feedback
4. **PR Comments** → Posts detailed review automatically

### **Redmine-Specific Features**
- ✅ **Plugin Standards**: Checks Redmine plugin conventions
- ✅ **Hook Security**: Validates hook implementations
- ✅ **Permission Checks**: Verifies role-based access
- ✅ **Route Protection**: Ensures proper authentication
- ✅ **View Conventions**: Checks Redmine layout standards

## 📋 **Review Categories**

### **Code Quality**
- Ruby/Rails best practices
- Redmine plugin conventions
- Code readability and maintainability

### **Security**
- Input validation and sanitization
- Authentication and authorization
- Plugin permission management
- SQL injection prevention

### **Performance**
- Database query optimization
- Caching implementation
- Resource usage efficiency

### **Testing**
- Test coverage verification
- Edge case testing
- Integration test validation

## 🔧 **Usage Instructions**

### **For Developers**
1. **Install Copilot Extension** in your IDE
2. **Open Plugin Files** in VS Code/Cursor
3. **Use Copilot Chat** (Ctrl+I) for manual reviews
4. **Reference Prompts** in `.copilot/prompts/`

### **For Pull Requests**
1. **Create PR** → Automatic review triggers
2. **Review Comments** → Detailed feedback posted
3. **Address Issues** → Fix based on recommendations
4. **Re-request Review** → Updated analysis

### **For Security Reviews**
1. **Use Security Prompt** for sensitive code
2. **Focus on OWASP Top 10** vulnerabilities
3. **Check Plugin Conflicts** with other plugins
4. **Verify Permissions** implementation

## 📊 **Review Template**

Each review includes:

```
## 🤖 Copilot Code Review - Redmine EVM Plugin

### ✅ Test Status
- All tests passed successfully
- Code coverage maintained

### 🔍 Code Quality Analysis
- RuboCop analysis completed
- Security scan passed
- Redmine plugin conventions verified

### 📝 Recommendations
- Specific improvement suggestions
- Redmine-specific best practices
- Security considerations

### 🔍 Redmine-Specific Checks
- Plugin initialization standards
- Route configuration
- View layout conventions
- Model class extensions

### 🚀 Next Steps
- Action items for improvement
- Performance optimizations
- Documentation updates
```

## ⚙️ **Configuration Options**

### **Settings File** (`.copilot/settings.json`)
```json
{
  "copilot": {
    "project": "redmine_issue_evm",
    "rules": {
      "redmine": {
        "plugin": true,
        "hooks": true,
        "permissions": true
      }
    },
    "paths": {
      "controllers": "app/controllers/**/*.rb",
      "models": "app/models/**/*.rb",
      "views": "app/views/**/*.erb"
    }
  }
}
```

### **Custom Prompts**
- **General Review**: `.copilot/prompts/review_prompt.md`
- **Security Review**: `.copilot/prompts/security_review.md`

## 🛠️ **Troubleshooting**

### **Common Issues**
1. **Workflow Not Triggering**: Check branch names (main/develop)
2. **Tests Failing**: Verify Ruby version and dependencies
3. **RuboCop Errors**: Check code style compliance
4. **Security Warnings**: Review CodeQL findings

### **Performance Optimization**
- Monitor workflow execution time
- Optimize test suite performance
- Reduce false positive reviews

## 🔒 **Security Considerations**

### **Plugin Security**
- Permission validation
- Input sanitization
- SQL injection prevention
- XSS protection

### **Data Protection**
- Sensitive data encryption
- Secure logging practices
- Error message security
- Access control enforcement

## 📈 **Best Practices**

### **Development Workflow**
1. **Write Tests First**: Ensure adequate coverage
2. **Follow Conventions**: Use Redmine plugin standards
3. **Document Changes**: Update README and comments
4. **Security Review**: Use security prompts for sensitive code

### **Code Quality**
1. **RuboCop Compliance**: Follow style guidelines
2. **Performance**: Optimize database queries
3. **Maintainability**: Write readable, well-structured code
4. **Compatibility**: Ensure Redmine version compatibility

---

For additional support, refer to:
- [Redmine Plugin Development Guide](https://www.redmine.org/projects/redmine/wiki/Plugin_Development)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Ruby on Rails Security Guide](https://guides.rubyonrails.org/security.html)
