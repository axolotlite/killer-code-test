**Taints and Tolerations**

### Tasks

1. **Add a taint** to `node01` to prevent normal pods from being scheduled  
    * **key:** `PERMISSION`  
    * **value:** `granted`  
    * **type:** `NoSchedule`  
2. **Schedule a Pod** on `node01` by adding the corresponding toleration  
    * **Name:** `nginx`  
    * **Image:** `nginx:stable`  

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.