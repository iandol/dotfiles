import csv
import random
from datetime import datetime, timedelta
import math

def generate_scientific_data(num_records=200):
    """
    Generate a mock CSV file with scientific environmental monitoring data.
    
    Parameters:
    - num_records (int): Number of records to generate
    
    Creates a CSV with columns:
    - timestamp: Date and time of measurement
    - site_id: Unique location identifier
    - site_name: Research site location
    - ecosystem_type: Type of ecosystem
    - temperature_celsius: Air temperature
    - humidity_percent: Relative humidity
    - precipitation_mm: Rainfall amount
    - soil_moisture_percent: Soil moisture content
    - biodiversity_index: Local biodiversity measurement
    - co2_ppm: Carbon dioxide concentration
    - researcher: Name of researcher collecting data
    """
    # Predefined lists for realistic data generation
    sites = [
        ("Alpine Meadow", "Alpine", 45.6, -110.5),
        ("Coastal Forest", "Temperate Rainforest", 47.8, -122.3),
        ("Desert Research Station", "Desert", 36.2, -112.1),
        ("Tropical Research Plot", "Tropical Rainforest", 4.7, -74.3),
        ("Arctic Research Base", "Tundra", 71.3, -156.6)
    ]
    
    researchers = [
        "Dr. Emily Chen", "Prof. Michael Rodriguez", 
        "Dr. Sarah Patel", "Dr. James Wilson", 
        "Dr. Aisha Nguyen", "Prof. Carlos Martinez"
    ]
    
    # Generate mock data
    mock_data = []
    start_date = datetime(2023, 1, 1)
    
    for _ in range(num_records):
        # Randomize date and time within the year
        current_date = start_date + timedelta(
            days=random.randint(0, 364),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59)
        )
        
        # Select random site
        site_name, ecosystem_type, latitude, longitude = random.choice(sites)
        
        # Generate realistic environmental measurements with some natural variation
        # Use sine waves to create more natural-looking periodic variations
        time_factor = (_ / num_records) * 2 * math.pi
        
        # Temperature variation based on ecosystem type
        base_temp = {
            "Alpine": 5,
            "Temperate Rainforest": 15,
            "Desert": 30,
            "Tropical Rainforest": 25,
            "Tundra": -10
        }[ecosystem_type]
        temperature = round(base_temp + 5 * math.sin(time_factor) + random.uniform(-2, 2), 2)
        
        # Humidity variation
        base_humidity = {
            "Alpine": 40,
            "Temperate Rainforest": 85,
            "Desert": 20,
            "Tropical Rainforest": 90,
            "Tundra": 50
        }[ecosystem_type]
        humidity = round(base_humidity + 10 * math.sin(time_factor) + random.uniform(-5, 5), 2)
        
        # Other measurements
        precipitation = round(max(0, base_humidity / 10 + 5 * math.sin(time_factor) + random.uniform(-2, 2)), 2)
        soil_moisture = round(humidity * 0.7 + random.uniform(-5, 5), 2)
        biodiversity_index = round(random.uniform(0.1, 1.0), 3)
        co2_ppm = round(400 + 50 * math.sin(time_factor) + random.uniform(-20, 20), 2)
        
        mock_record = {
            "timestamp": current_date.strftime("%Y-%m-%d %H:%M:%S"),
            "site_id": f"SITE-{random.randint(1000, 9999)}",
            "site_name": site_name,
            "ecosystem_type": ecosystem_type,
            "latitude": latitude,
            "longitude": longitude,
            "temperature_celsius": temperature,
            "humidity_percent": humidity,
            "precipitation_mm": precipitation,
            "soil_moisture_percent": soil_moisture,
            "biodiversity_index": biodiversity_index,
            "co2_ppm": co2_ppm,
            "researcher": random.choice(researchers)
        }
        
        mock_data.append(mock_record)
    
    # Write to CSV
    output_file = "scientific_environmental_data.csv"
    
    # Specify the columns in a specific order
    fieldnames = [
        "timestamp", "site_id", "site_name", "ecosystem_type", 
        "latitude", "longitude", "temperature_celsius", 
        "humidity_percent", "precipitation_mm", 
        "soil_moisture_percent", "biodiversity_index", 
        "co2_ppm", "researcher"
    ]
    
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        # Write header
        writer.writeheader()
        
        # Write data
        writer.writerows(mock_data)
    
    print(f"Scientific environmental data generated: {output_file}")
    print(f"Generated {num_records} records")

# Generate the mock scientific data
generate_scientific_data(1000)  # Generate 500 records by default