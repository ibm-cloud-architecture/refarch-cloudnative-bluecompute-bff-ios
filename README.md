# refarch-cloudnative-bluecompute-bff-ios

*This project is part of the 'IBM Cloud Native Reference Architecture' suite, available at
https://github.com/ibm-cloud-architecture/refarch-cloudnative*

This project sits between the iOS Application and the `Object Storage` Service. It is built with Swift 3.0 and Kitura web framework with following functionality:

- Serve the application images stored in the Bluemix [Object Storage](https://console.ng.bluemix.net/catalog/object-storage/) service

The Swift code is located in the `Sources` folder.

## Pre-requisites
1. **[Provision](https://console.ng.bluemix.net/catalog/object-storage/) an instance of `Object Storage` into your Bluemix space.**
  - Select name for your instance.
  - Click the `Create` button.
  - Note:
    - You can only provision one Free instance of `Object Storage` per Bluemix organization.
2. **Once provisioned, obtain `Object Storage` service credentials.**
  - Click on `Service Credentials` tab.
  - Then click on the `View Credentials` dropdown next to the credentials.
3. **You will need the following:**
  - **projectId:** Object Storage Open Stack project id.
  - **userId:** Object Storage user.
  - **password:** Object Storage password.
4. Keep those credential handy as they will be needed throughout the rest of this document.

## Run the application locally:
1. If not already done, provision an instance of [Object Storage](#pre-requisites).
2. **Open `env.sh` and enter the following `Object Storage` credentials collected in the [Pre-requisites](#pre-requisites):**
  - projectId
  - userId
  - password
3. **Load credentials into environment**
    ```
    # source env.sh
    ```
  
4. **Run the application:**
    ```
    # swift build
    # ./.build/debug/bluecompute-bff-ios
    ```

  - This will start the application on port 8090.

5. **Validate the local application:**
  - [http://localhost:8090/image/collator.jpg](http://localhost:8090/image/collator.jpg)


## Deploy to Bluemix Cloud Foundry runtime:
1. If not already done, provision an instance of [Object Storage](#pre-requisites).
2. **Open `manifest.yml` and enter the following `Object Storage` credentials collected in the [Pre-requisites](#pre-requisites):**
  - projectId
  - userId
  - password
3. **Deploy application to Cloud Foundry:**
    ```
    # cf push
    ```
  
4. **Validate the Cloud Foundry application:**
  - [https://bluecompute-bff-ios.mybluemix.net/image/collator.jpg](https://bluecompute-bff-ios.mybluemix.net/image/collator.jpg)

## Run application in local docker container
1. If not already done, provision an instance of [Object Storage](#pre-requisites).
2. **Build container image:**
    ```
    # docker build -t cloudnative/bluecompute-bff-ios .
    ```

3. **Start the application in docker container:**
    ```
    # docker run -i -d -p 8090:8090 --name bluecompute-bff-ios \
      -e "projectId={OS_PROJECT_ID}" \
      -e "userId={OS_USER_ID}" \
      -e "password={OS_PASSWORD}" \
      cloudnative/bluecompute-bff-ios
    ```

  - Replace {OS_PROJECT_ID} with the `Object Storage` project id.
  - Replace {OS_USER_ID} with the `Object Storage` user id.
  - Replace {OS_PASSWORD} with the `Object Storage` password.

4. **Validate the local docker application:**
  - [http://localhost:8090/image/collator.jpg](http://localhost:8090/image/collator.jpg)

##Deploy Mobile BFF Service application on Bluemix container
In this section you will deploy the Mobile BFF application to run in IBM Bluemix containers.

1. **Log in to your Bluemix account**.
    ```
    # cf login -a <bluemix-api-endpoint> -u <your-bluemix-user-id>
    ```

2. **Set target to use your Bluemix Org and Space**.
    ```
    # cf target -o <your-bluemix-org> -s <your-bluemix-space>
    ```

3. **Log in to IBM Containers plugin**.
    ```
    # cf ic login
    ```

4. **Build container image**
    ```
    # docker build -t cloudnative/bluecompute-bff-ios .
    ```

5. **Tag and push the local docker image to bluemix private registry**.
    ```
    # docker tag cloudnative/bluecompute-bff-ios registry.ng.bluemix.net/$(cf ic namespace get)/bluecompute-bff-ios:cloudnative
    # docker push registry.ng.bluemix.net/$(cf ic namespace get)/bluecompute-bff-ios:cloudnative
    ```

6. If not already done, provision an instance of [Object Storage](#pre-requisites).

7. **Start the application in IBM Bluemix container**.
  ```
    # cf ic group create -p 8090 -m 1024 --min 1 --auto --name bluecompute-bff-ios \
    -e "projectId={OS_PROJECT_ID}" \
    -e "userId={OS_USER_ID}" \
    -e "password={OS_PASSWORD}" \
    -n bluecompute-bff-ios \
    -d mybluemix.net registry.ng.bluemix.net/$(cf ic namespace get)/bluecompute-bff-ios:cloudnative
    ```

  - Replace {OS_PROJECT_ID} with the `Object Storage` project id.
  - Replace {OS_USER_ID} with the `Object Storage` user id.
  - Replace {OS_PASSWORD} with the `Object Storage` password.

7. **Validate. Open a browser and enter the following:**
  - [https://bluecompute-bff-ios.mybluemix.net/image/collator.jpg](https://bluecompute-bff-ios.mybluemix.net/image/collator.jpg)