import boto3
import click


def get_current_task_definition(client, cluster, service):
    response = client.describe_services(cluster=cluster, services=[service])
    current_task_arn = response["services"][0]["taskDefinition"]
    return client.describe_task_definition(taskDefinition=current_task_arn)


@click.command()
@click.option("--cluster", help="Name of the ECS cluster", required=True)
@click.option("--service", help="Name of the ECS service", required=True)
@click.option("--image", help="Docker image URL for the updated application", required=True)
@click.option("--profile", help="AWS CLI profile to use", default="wewoli")
@click.option("--region", help="AWS region", default="us-east-1")
def deploy(cluster, service, image, profile, region):

    client = boto3.client("ecs", region_name=region)
    session = boto3.Session(profile_name=profile)

    # Fetch the current task definition
    try:
        print("Fetching current task definition...")
        response = get_current_task_definition(client, cluster, service)
        container_definition = response["taskDefinition"]["containerDefinitions"][0].copy()
        print(f"Current task definition fetched: {response['taskDefinition']['taskDefinitionArn']}")
    except client.exceptions.ClientError as e:
        print(f"Error fetching task definition: {e}")

    # Update the container definition with the new image
    print("Updating container definition with new image...")
    if "image" not in container_definition:
        print(f"Image key not found in container definition: {container_definition}")
        print("Image key not found in container definition. Adding it now.")
    container_definition["image"] = image
    print(f"Updated image to: {image}")


    # Register a new task definition

    try:

        print("Registering new task definition...")
        response = client.register_task_definition(
            family=response["taskDefinition"]["family"],
            volumes=response["taskDefinition"]["volumes"],
            containerDefinitions=[container_definition],
            cpu="256",  # Modify based on your needs
            memory="512",  # Modify based on your needs
            networkMode="awsvpc",
            requiresCompatibilities=["FARGATE"],
            executionRoleArn="ecs_task_execution_role_prod",
            taskRoleArn="ecs_task_execution_role_prod"
        )
        new_task_arn = response["taskDefinition"]["taskDefinitionArn"]
        print(f"New task definition ARN: {new_task_arn}")

        # Update the service with the new task definition
        print("Updating ECS service with new task definition...")
        client.update_service(
            cluster=cluster, service=service, taskDefinition=new_task_arn,
        )
    except client.exceptions.ClientError as e:
        print(f"Error registering new task definition: {e}")
        return
    print("Service updated!")


if __name__ == "__main__":
    deploy()
