aws deploy create-deployment \
--application-name devops-demo \
--deployment-config-name CodeDeployDefault.OneAtATime \
--deployment-group-name devops-demo-dgroup1 \
--description "$1" \
--s3-location bucket=devops-demo-video,bundleType=zip,key=devops-demo-dist.zip \
--ignore-application-stop-failures