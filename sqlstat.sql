import pyodbc

# Database connection setup
conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=your_server_name;"
    "DATABASE=ReportServer;"
    "UID=your_username;"
    "PWD=your_password;"
)
connection = pyodbc.connect(conn_str)
cursor = connection.cursor()

# Define the subscription ID you want to update
subscription_id = 'b7e97efc-0859-4f5f-931f-202ed8e6727a'

try:
    # Step 1: Retrieve all date values from the date_list table
    select_dates_query = "SELECT CAST(date_column AS NVARCHAR(50)) AS date_value FROM dbo.date_list"  # Replace 'date_column' with the actual column name in date_list
    cursor.execute(select_dates_query)
    date_rows = cursor.fetchall()
    
    # Step 2: Loop through each date value, update the parameter, and call the stored procedure
    for date_row in date_rows:
        date_value = date_row.date_value
        print(f"Updating subscription with date: {date_value}")

        # Step 3: Update the Parameters column with the current date value
        update_query = """
        DECLARE @NewParameterValue NVARCHAR(50) = ?;
        DECLARE @SubscriptionID UNIQUEIDENTIFIER = ?;

        -- Convert NTEXT to XML for modification, and perform the update
        DECLARE @ParametersXML XML;

        SELECT @ParametersXML = CAST(Parameters AS XML)
        FROM dbo.Subscriptions
        WHERE SubscriptionID = @SubscriptionID;

        -- Modify the XML
        SET @ParametersXML.modify('
            replace value of (/Parameters/Parameter[Name="ReportDate"]/Value/text())[1]
            with sql:variable("@NewParameterValue")
        ');

        -- Update the Parameters column with the modified XML, casting to NVARCHAR(MAX)
        UPDATE dbo.Subscriptions
        SET Parameters = CAST(@ParametersXML AS NVARCHAR(MAX))
        WHERE SubscriptionID = @SubscriptionID;
        """

        # Execute the update query with the current date value
        cursor.execute(update_query, (date_value, subscription_id))
        connection.commit()
        print(f"Subscription parameter updated with date: {date_value}")

        # Step 4: Call the stored procedure to trigger the subscription
        cursor.execute("EXEC sp_main_trigger_subscription")
        connection.commit()
        print("Subscription triggered successfully.")

except Exception as e:
    print("An error occurred:", e)

finally:
    # Close the database connection
    cursor.close()
    connection.close()
