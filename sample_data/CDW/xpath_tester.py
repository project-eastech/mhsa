import argparse
from lxml import etree

def extract_trade_ids(xml_file, xpath_expr, namespace=True):
    # Load the XML file
    tree = etree.parse(xml_file)

    # Define namespaces used in the XML (including the default namespace)
    namespaces = {
        "m": "urn:com.mizuho.bdm",  # Prefix 'm' for Mizuho namespace
        "fpml": "http://www.fpml.org/FpML-5/reporting",  # Default FpML namespace
        "xsi": "http://www.w3.org/2001/XMLSchema-instance"
    }
    
    if namespace:
        values = tree.xpath(xpath_expr, namespaces=namespaces)
    else:
        values = tree.xpath(xpath_expr)
    # namespace debug
    #for elem in tree.iter():
    #    print(elem.tag)

    # Print the trade IDs
    if values:
        for idx, value in enumerate(values, start=1):
            if isinstance(value, etree._Element):  # If it's an XML Element
                print(f"Value {idx}: {value.text}")  # Print element text
            else:  # If it's an attribute or direct text content
                print(f"Value {idx}: {value}")  # Print string value directly
    else:
        print("No values found with the given XPath expression.")

if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Extract tradeId using XPath from an XML file.")
    parser.add_argument("xml_file", type=str, help="Path to the XML file.")
    parser.add_argument("namespace", type=bool, help="Using namespace.")
    parser.add_argument("xpath_expr", type=str, help="XPath expression to extract tradeId.")

    args = parser.parse_args()

    # Call function with user-provided arguments
    extract_trade_ids(args.xml_file, args.xpath_expr, args.namespace)
