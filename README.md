# Step 1: Run the infrastructure script
Run the command in INIT.md, this will generate VCN + OKE cluster with:
* cert-manager
* metrics-server
* Istio + Istio ingressGateway
* KNative
* KServe

Have a look at the oke cluster, also notice the LB and annotate the NSG OCID value.  
Then, open the code editor into the cloned directory

# Step 2: Install MLFlow

* Be sure to be in the right folder for all the steps below:  
`cd $HOME/$OCI_CCL_DESTINATION_DIR`
* Create a customer secret key. **Write down** id and key:  
  `oci iam customer-secret-key create --display-name s3-mlflow --user-id $OCI_CS_USER_OCID`

* Get the value of the namespace and current region key, be sure to **write down** these values in a text editor:
  ```
    oci os ns get --query data --raw-output
    echo $OCI_REGION
  ```
* Create mlflow bucket through the web console
* Substitute all the value placeholders in **mlflow/values.yaml**:  
  `vim mlflow/values.yaml`
* Run:  
``` helm install oke-mlflow oci://registry-1.docker.io/bitnamicharts/mlflow -n mlflow --create-namespace -f mlflow/values.yaml ```
* Get the endpoint, user and password to access the MLFlow server. Be sure to **write down** MLFlow endpoint, user and password:  
```
    export SERVICE_IP=$(kubectl get svc --namespace mlflow oke-mlflow-tracking --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
    echo "MLflow URL: http://$SERVICE_IP/"
    echo Username: $(kubectl get secret --namespace mlflow oke-mlflow-tracking -o jsonpath="{ .data.admin-user }" | base64 -d)
    echo Password: $(kubectl get secret --namespace mlflow oke-mlflow-tracking -o jsonpath="{.data.admin-password }" | base64 -d)
```
* Explore the MLFlow interface

# Step 3: OCI Data Science

* Create OCI Data Science project, default values are enough
* Clone repository https://github.com/alcampag/oke-mlops.git
* Open a terminal (File -> New -> Terminal) and run:  
```
pip3 install oci-mlflow
pip3 install boto3
```
* Open mlflow.ipynb
* Fill out the values with the ones we have collected in Step 2
* Run the notebook, restart kernel in case of errors

# Step 4: Configure KServe and deploy the model

* Go in the MLFlow interface, select a model to deploy and **write down** the artifact path
* Fill in the file kserve/s3creds.yaml with the values we have previously annotated, then run:  
```
kubectl apply -f kserve/s3creds.yaml
kubectl apply -f kserve/sa.yaml
```
* Knowing the artifact path, open kserve/inferenceService.yaml and configure it, then run these commands to deploy the model:
```
kubectl apply -f kserve/inferenceService.yaml
kubectl describe inferenceservice.serving.kserve.io/wine-predictor
kubectl get inferenceservice.serving.kserve.io/wine-predictor
```
* Test the inference endpoint with a sample call, be sure to replace the IP from the following command:  
``` curl -v -H "Content-Type: application/json" -d @./input.json http://wine-predictor.default.{ingress-IP}.sslip.io/v2/models/wine-predictor/infer ```


[![Open in Code Editor](https://raw.githubusercontent.com/oracle-devrel/oci-code-editor-samples/main/images/open-in-code-editor.png)](https://cloud.oracle.com/?region=home&cs_repo_url=https://github.com/alcampag/oke-mlops.git&cs_branch=main&cs_readme_path=INIT.md&cs_open_ce=false)

