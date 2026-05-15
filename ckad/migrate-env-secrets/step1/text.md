**Migrate Environment Variables to Secrets**

### Tasks

1. **Create a Secret** named `database-secret` in the `production` namespace with the following keys from the deployment:

   * `username`
   * `password`
   * `dbname`

2. **Modify the existing `webapp` Deployment** in the `production` namespace to reference the Secret instead of hardcoded values:

   * `DB_USER` → references key `username` from `database-secret`
   * `DB_PASS` → references key `password` from `database-secret`
   * `DB_NAME` → references key `dbname` from `database-secret`

3. **Ensure the Deployment rolls out successfully** after the changes

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.