#File-Based CMS
This is a basic file-based content management system.  All users share the same files.


##Instructions

* Enter `$ ruby cms.rb` from the root folder to start the application

* Once the application starts, go to the index page ('/').  Here you will see a list of all the current documents managed by the system.  In order to carry out functions such as editing content or deleting files, you must be logged in.  At the bottom of the page, there is a 'Sign In' button.  Click that button to go to the login page.

* You can use the following credentials to log in:  username: piglet 
password: robin



##Development
This application was built using Ruby 2.3.0p0.  It addresses the following concepts:

- Processing HTTP requests and responses
- Session storage
- Basic session-based authentication
- Restriction of site features based on user's authentication status
- Testing
- Validation of user input
- Sanitizing HTML
- File input and output
- Using route filters
- Creating, editing, and deleting resources
- Creating flash messages for a better user experience
- Code refactoring