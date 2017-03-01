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
5. **Create an Object Storage container. Bluemix Object Storage uses `container` as unit of managing content.**
  - Click the "Manage" tab, then click the `Select Action` dropdown, and choose `Create Container`.
  - Name the Container `bluecompute`.
6. **Upload the application images into the container.**
  - From your compute file explore (or Finder in Mac), locate the `image` folder. 
  - Drag and drop all the images to the Browser Object Storage `bluecompute` container. 
    - Alternatively, you can click add file actions to load images.

## Deploy BlueCompute iOS BFF using DevOps Toolchain
You can use the following button to deploy the BlueCompute iOS BFF to Bluemix, or you can follow the manual instructions in the following sections. If you decide on the toolchain button, you have to fulfill the following pre-requisites:
- **[Provision](#pre-requisites) an Object Storage service instance in your Bluemix Space**.
  - The toolchain will automatically pick up the `Object Storage` credentials.

[![Create BlueCompute Deployment Toolchain](https://console.ng.bluemix.net/devops/graphics/create_toolchain_button.png)](https://console.ng.bluemix.net/devops/setup/deploy?repository=https://github.com/ibm-cloud-architecture/refarch-cloudnative-bluecompute-bff-ios.git)

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

4. **Alternatively, you can bind existing `Object Storage` instance directly to cf app:**
    ```
    cf push bluecompute-bff-ios -n bluecompute-bff-ios -d "mybluemix.net" --no-start
    cf bind-service bluecompute-bff-ios objectstorage-instance-name
    cf start bluecompute-bff-ios
    ```

5. **Validate the Cloud Foundry application:**
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