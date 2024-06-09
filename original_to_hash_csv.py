import pandas as pd
import hashlib


def calculate_hash(row):
    # Join all values in the row except the last column (hash)
    data_string = ''.join(str(value) for value in row[:-1])
    # Create SHA256 hash of the data string
    return hashlib.sha256(data_string.encode('utf-8')).hexdigest()


def add_pid_and_hash_to_csv(input_csv, output_csv):
    # Read the CSV file
    df = pd.read_csv(input_csv)

    # Add 'pid' column starting from 1 to the length of the dataframe
    df.insert(0, 'pid', range(1, len(df) + 1))

    # Ensure 'hash' column is present
    if 'hash' not in df.columns:
        df['hash'] = ''

    # Calculate the hash for each row and update the 'hash' column
    df['hash'] = df.apply(calculate_hash, axis=1)

    # Save the updated dataframe to a new CSV file
    df.to_csv(output_csv, index=False)


# Example usage
input_csv = 'example.csv'
output_csv = 'example_hash.csv'
add_pid_and_hash_to_csv(input_csv, output_csv)
