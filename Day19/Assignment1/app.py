import os

participant = os.getenv("PARTICIPANT_NAME", "Unknown")

print(f"Hello {participant} from ECS Application")