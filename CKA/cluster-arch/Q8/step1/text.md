**CKA Lab 08: CNI Installation**

### Tasks

Install a **CNI** of your choice that meets the following criteria:  

* **Pod-to-Pod communication** works  
* Supports **NetworkPolicies**  
* Installed via a **manifest**  

**Options:**

* **Flannel (v0.27.4)**:

  ```text
  https://github.com/flannel-io/flannel/releases/download/v0.27.4/kube-flannel.yml
  ```{{copy}}

* **Calico (v3.30.6)**:

  ```text
  https://raw.githubusercontent.com/projectcalico/calico/refs/tags/v3.30.6/manifests/tigera-operator.yaml
  ```{{copy}}

**Note:**  
Ensure that the nodes are `Ready`  

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.