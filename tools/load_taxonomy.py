import csv
import pprint


def load_taxonomy(file_path):
    taxonomy = {}
    columns = [[], [], [], [], [], []]
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            for i, value in enumerate(row):
                columns[i].append(value)
        for column in columns:
            taxonomy[column[0]] = column[1:]
    return taxonomy


def main():
    file_path = 'data/taxonomy.csv'
    taxonomy = load_taxonomy(file_path)
    pprint.pprint(taxonomy, compact=True, width=120)


if __name__ == '__main__':
    main()
