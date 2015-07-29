Atlassian JIRA
--------------

- Runs JIRA as non-root in a container.
- Keeps the application-data folder in a separate persistent volume allowing (I hope) transparent updates and restarting the instance if the container crashes. 

this is a work in progress...
