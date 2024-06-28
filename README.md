# Step 1
Run the command in INIT.md, this will generate VCN + OKE cluster with:
* cert-manager
* metrics-server
* Istio + Istio ingressGateway
* KNative
* KServe

----------------------------------------
Have a look at the oke cluster, also notice the LB and annotate the NSG OCID value
Then, cd into the cloned directory
----------------------------------------

# Step 2
Install MLFlow:
----------------------------------
oci iam customer-secret-key create --display-name s3-mlflow --user-id $OCI_CS_USER_OCID
Annotate id and key
oci os ns get --query data --raw-output
Annotate value (it's the namespace name)
echo $OCI_REGION
Annotate value (REGION KEY)
With all this values, substitute them in mlflow/values.yaml
helm install oke-mlflow oci://registry-1.docker.io/bitnamicharts/mlflow -n mlflow --create-namespace -f mlflow/values.yaml
----------------------------------


[![Open in Code Editor](https://raw.githubusercontent.com/oracle-devrel/oci-code-editor-samples/main/images/open-in-code-editor.png)](https://cloud.oracle.com/?region=home&cs_repo_url=https://github.com/alcampag/oke-mlops.git&cs_branch=main&cs_readme_path=INIT.md&cs_open_ce=false)

