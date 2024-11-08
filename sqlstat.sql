CREATE PROCEDURE UpdateDynamicSubscriptionParameters
    @SubscriptionID UNIQUEIDENTIFIER,
    @NewParameterValue1 NVARCHAR(50) = NULL,
    @NewParameterValue2 NVARCHAR(50) = NULL,
    @NewParameterValue3 NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ParametersXML XML;

    -- Step 1: Retrieve the current Parameters XML, cast from NTEXT to XML
    SELECT @ParametersXML = CAST(Parameters AS XML)
    FROM ReportServer.dbo.Subscriptions
    WHERE SubscriptionID = @SubscriptionID;

    -- Check if the Parameters XML was successfully retrieved
    IF @ParametersXML IS NOT NULL
    BEGIN
        DECLARE @ParameterNames TABLE (ParameterName NVARCHAR(50), ParameterIndex INT);

        -- Step 2: Extract all parameter names and their order
        INSERT INTO @ParameterNames (ParameterName, ParameterIndex)
        SELECT T.ParameterName.value('.', 'NVARCHAR(50)') AS ParameterName, 
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ParameterIndex
        FROM @ParametersXML.nodes('/Parameters/Parameter/Name') AS T(ParameterName);

        -- Update each parameter based on the number of new values provided and available parameters
        IF EXISTS (SELECT 1 FROM @ParameterNames WHERE ParameterIndex = 1) AND @NewParameterValue1 IS NOT NULL
        BEGIN
            DECLARE @ParameterName1 NVARCHAR(50);
            SELECT @ParameterName1 = ParameterName FROM @ParameterNames WHERE ParameterIndex = 1;

            SET @ParametersXML.modify('
                replace value of (/Parameters/Parameter[Name=sql:variable("@ParameterName1")]/Value/text())[1]
                with sql:variable("@NewParameterValue1")
            ');
        END

        IF EXISTS (SELECT 1 FROM @ParameterNames WHERE ParameterIndex = 2) AND @NewParameterValue2 IS NOT NULL
        BEGIN
            DECLARE @ParameterName2 NVARCHAR(50);
            SELECT @ParameterName2 = ParameterName FROM @ParameterNames WHERE ParameterIndex = 2;

            SET @ParametersXML.modify('
                replace value of (/Parameters/Parameter[Name=sql:variable("@ParameterName2")]/Value/text())[1]
                with sql:variable("@NewParameterValue2")
            ');
        END

        IF EXISTS (SELECT 1 FROM @ParameterNames WHERE ParameterIndex = 3) AND @NewParameterValue3 IS NOT NULL
        BEGIN
            DECLARE @ParameterName3 NVARCHAR(50);
            SELECT @ParameterName3 = ParameterName FROM @ParameterNames WHERE ParameterIndex = 3;

            SET @ParametersXML.modify('
                replace value of (/Parameters/Parameter[Name=sql:variable("@ParameterName3")]/Value/text())[1]
                with sql:variable("@NewParameterValue3")
            ');
        END

        -- Step 4: Update the Parameters column with the modified XML, cast back to NTEXT
        UPDATE ReportServer.dbo.Subscriptions
        SET Parameters = CAST(@ParametersXML AS NTEXT)
        WHERE SubscriptionID = @SubscriptionID;

        PRINT 'Parameters updated successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Subscription not found or Parameters XML is NULL.';
    END
END;
GO
