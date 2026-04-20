**CKA Lab 03: Sidecar Container Pattern**

### Tasks

Update the existing **nginx deployment** in namespace `nginx` by adding a colocated **sidecar container** to the deployment's **containers**.

You can find the **nginx deployment** manifest at `~/deployment`

**Sidecar container specifications:**  
* **Name:** `sidecar`  
* **Image:** `busybox:stable`  
* **Command:** `/bin/sh -c "tail -f /var/log/nginx/access.log"`  

Use a **shared volume** mounted at `/var/log` to make the `access.log` file accessible to the sidecar container.


**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.