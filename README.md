# Step 1
Run the command in INIT.md, this will generate VCN + OKE cluster with:
* cert-manager
* metrics-server
* Istio + Istio ingressGateway
* KNative
* KServe

----------------------------------------
Have a look at the oke cluster, also notice the LB and annotate the NSG OCID value
Then, open the code editor into the cloned directory
----------------------------------------

# Step 2
Install MLFlow:
----------------------------------
cd $OCI_CCL_DESTINATION_DIR
oci iam customer-secret-key create --display-name s3-mlflow --user-id $OCI_CS_USER_OCID
Annotate id and key
oci os ns get --query data --raw-output
Annotate value (it's the namespace name)
echo $OCI_REGION
Annotate value (REGION KEY)
Create mlflow bucket
With all this values, substitute them in mlflow/values.yaml
helm install oke-mlflow oci://registry-1.docker.io/bitnamicharts/mlflow -n mlflow --create-namespace -f mlflow/values.yaml

export SERVICE_IP=$(kubectl get svc --namespace mlflow oke-mlflow-tracking --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "MLflow URL: http://$SERVICE_IP/"
echo Username: $(kubectl get secret --namespace mlflow oke-mlflow-tracking -o jsonpath="{ .data.admin-user }" | base64 -d)
echo Password: $(kubectl get secret --namespace mlflow oke-mlflow-tracking -o jsonpath="{.data.admin-password }" | base64 -d)
Annotate user and password
Try to access MLFlow interface
----------------------------------
# Step 3
Configure KServe:
----------------------------------
Fill in the file kserve/s3creds.yaml with the values we have previously annotated
kubectl apply -f kserve/s3creds.yaml
kubectl apply -f kserve/sa.yaml
----------------------------------
# Step 4
OCI Data Science:
----------------------------------
Create OCI Data Science project, default values are enough
Clone repository https://github.com/alcampag/oke-mlops.git
Open terminal (File -> New -> Terminal)
pip3 install oci-mlflow
pip3 install boto3
In case, restart kernel
Open mlflow.ipynb
Fill out the values with the ones we have collected
Run the notebook
----------------------------------
# Step 5
Deploy a model
----------------------------------
Go in the MLFlow interface, select a model to deploy and annotate the model path
Fill in kserve/inferenceService.yaml
kubectl apply -f kserve/inferenceService.yaml
kubectl describe inferenceservice.serving.kserve.io/wine-predictor
kubectl get inferenceservice.serving.kserve.io/wine-predictor
curl -v -H "Content-Type: application/json" -d @./input.json http://wine-predictor.default.{ingress-IP}.sslip.io/v2/models/wine-predictor/infer


[![Open in Code Editor](https://raw.githubusercontent.com/oracle-devrel/oci-code-editor-samples/main/images/open-in-code-editor.png)](https://cloud.oracle.com/?region=home&cs_repo_url=https://github.com/alcampag/oke-mlops.git&cs_branch=main&cs_readme_path=INIT.md&cs_open_ce=false)

