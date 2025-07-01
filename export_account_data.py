#!/usr/bin/env python3
"""
Account Data Export Script

Exports comprehensive JSON data for a given account number from the DCAD property appraisal database.
Includes data from all tables in the hierarchy: account_info (primary), direct dependencies, 
and secondary dependencies through taxable_object.

Usage:
    python export_account_data.py --account-num 00000100012000000 --year 2024
    python export_account_data.py --account-num 00000100012000000 --all-years
    python export_account_data.py --account-num 00000100012000000 --output account_data.json
"""

import argparse
import json
import sys
import boto3
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, date
import decimal

class DecimalEncoder(json.JSONEncoder):
    """Custom JSON encoder to handle decimal and date types"""
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return float(obj)
        elif isinstance(obj, (datetime, date)):
            return obj.isoformat()
        return super(DecimalEncoder, self).default(obj)

class AccountDataExporter:
    def __init__(self):
        self.conn = None
        self.cursor = None
        
    def connect_to_database(self):
        """Connect to the Aurora PostgreSQL database"""
        try:
            # Get database password from AWS Secrets Manager
            secrets_client = boto3.client('secretsmanager', region_name='us-west-2')
            response = secrets_client.get_secret_value(SecretId='aurora-postgres-password')
            password = response['SecretString']
            
            # Connect to database
            self.conn = psycopg2.connect(
                host='map-appraiser-aurora-db-cluster.cluster-cjcydnj4gvc0.us-west-2.rds.amazonaws.com',
                port=5432,
                database='map_appraiser',
                user='postgres',
                password=password
            )
            self.cursor = self.conn.cursor(cursor_factory=RealDictCursor)
            print("✅ Connected to database successfully")
            
        except Exception as e:
            print(f"❌ Error connecting to database: {e}")
            sys.exit(1)
    
    def close_connection(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
    
    def get_account_info(self, account_num, year=None):
        """Get primary account information"""
        query = "SELECT * FROM appraisal.account_info WHERE account_num = %s"
        params = [account_num]
        
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        
        query += " ORDER BY appraisal_yr DESC"
        
        self.cursor.execute(query, params)
        return self.cursor.fetchall()
    
    def get_account_apprl_year(self, account_num, year=None):
        """Get annual appraisal data"""
        query = "SELECT * FROM appraisal.account_apprl_year WHERE account_num = %s"
        params = [account_num]
        
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        
        query += " ORDER BY appraisal_yr DESC"
        
        self.cursor.execute(query, params)
        return self.cursor.fetchall()
    
    def get_taxable_objects(self, account_num, year=None):
        """Get taxable objects for the account"""
        query = "SELECT * FROM appraisal.taxable_object WHERE account_num = %s"
        params = [account_num]
        
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        
        query += " ORDER BY appraisal_yr DESC, tax_obj_id"
        
        self.cursor.execute(query, params)
        return self.cursor.fetchall()
    
    def get_land_data(self, account_num, year=None):
        """Get land parcel data"""
        query = "SELECT * FROM appraisal.land WHERE account_num = %s"
        params = [account_num]
        
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        
        query += " ORDER BY appraisal_yr DESC, section_num"
        
        self.cursor.execute(query, params)
        return self.cursor.fetchall()
    
    def get_exemptions_data(self, account_num, year=None):
        """Get all exemption data"""
        exemptions = {}
        
        # Applied standard exemptions
        query = "SELECT * FROM appraisal.applied_std_exempt WHERE account_num = %s"
        params = [account_num]
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY appraisal_yr DESC, owner_seq_num"
        
        self.cursor.execute(query, params)
        exemptions['applied_std_exempt'] = self.cursor.fetchall()
        
        # Account exemption values
        query = "SELECT * FROM appraisal.acct_exempt_value WHERE account_num = %s"
        params = [account_num]
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY appraisal_yr DESC, exemption_cd"
        
        self.cursor.execute(query, params)
        exemptions['acct_exempt_value'] = self.cursor.fetchall()
        
        # Abatement exemptions
        query = "SELECT * FROM appraisal.abatement_exempt WHERE account_num = %s"
        params = [account_num]
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY appraisal_yr DESC"
        
        self.cursor.execute(query, params)
        exemptions['abatement_exempt'] = self.cursor.fetchall()
        
        # Freeport exemptions
        query = "SELECT * FROM appraisal.freeport_exemption WHERE account_num = %s"
        params = [account_num]
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY appraisal_yr DESC"
        
        self.cursor.execute(query, params)
        exemptions['freeport_exemption'] = self.cursor.fetchall()
        
        # Total exemptions
        query = "SELECT * FROM appraisal.total_exemption WHERE account_num = %s"
        params = [account_num]
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY appraisal_yr DESC"
        
        self.cursor.execute(query, params)
        exemptions['total_exemption'] = self.cursor.fetchall()
        
        return exemptions
    
    def get_other_direct_dependencies(self, account_num, year=None):
        """Get other tables that directly reference account_info"""
        other_data = {}
        
        # Multi-owner data
        query = "SELECT * FROM appraisal.multi_owner WHERE account_num = %s"
        params = [account_num]
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY appraisal_yr DESC, owner_seq_num"
        
        self.cursor.execute(query, params)
        other_data['multi_owner'] = self.cursor.fetchall()
        
        # TIF data
        query = "SELECT * FROM appraisal.account_tif WHERE account_num = %s"
        params = [account_num]
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY appraisal_yr DESC"
        
        self.cursor.execute(query, params)
        other_data['account_tif'] = self.cursor.fetchall()
        
        return other_data
    
    def get_appraisal_notices(self, account_num, year=None):
        """Get appraisal notices data"""
        query = "SELECT * FROM appraisal.appraisal_notices WHERE account_num = %s"
        params = [account_num]
        
        if year:
            query += " AND appraisal_yr = %s"
            params.append(year)
        
        query += " ORDER BY appraisal_yr DESC, property_type"
        
        self.cursor.execute(query, params)
        return self.cursor.fetchall()
    
    def get_appraisal_review_board(self, account_num, year=None):
        """Get appraisal review board (protest) data"""
        query = "SELECT * FROM appraisal.appraisal_review_board WHERE account_num = %s"
        params = [account_num]
        
        if year:
            query += " AND protest_yr = %s"
            params.append(year)
        
        query += " ORDER BY protest_yr DESC"
        
        self.cursor.execute(query, params)
        return self.cursor.fetchall()
    
    def get_property_details(self, account_num, year=None):
        """Get secondary dependencies (property detail tables)"""
        details = {}
        
        # Residential details
        query = """
        SELECT rd.* FROM appraisal.res_detail rd
        JOIN appraisal.taxable_object to_obj ON 
            rd.account_num = to_obj.account_num AND 
            rd.appraisal_yr = to_obj.appraisal_yr AND 
            rd.tax_obj_id = to_obj.tax_obj_id
        WHERE rd.account_num = %s
        """
        params = [account_num]
        if year:
            query += " AND rd.appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY rd.appraisal_yr DESC, rd.tax_obj_id"
        
        self.cursor.execute(query, params)
        details['res_detail'] = self.cursor.fetchall()
        
        # Commercial details
        query = """
        SELECT cd.* FROM appraisal.com_detail cd
        JOIN appraisal.taxable_object to_obj ON 
            cd.account_num = to_obj.account_num AND 
            cd.appraisal_yr = to_obj.appraisal_yr AND 
            cd.tax_obj_id = to_obj.tax_obj_id
        WHERE cd.account_num = %s
        """
        params = [account_num]
        if year:
            query += " AND cd.appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY cd.appraisal_yr DESC, cd.tax_obj_id"
        
        self.cursor.execute(query, params)
        details['com_detail'] = self.cursor.fetchall()
        
        # Additional residential improvements
        query = """
        SELECT ra.* FROM appraisal.res_addl ra
        JOIN appraisal.taxable_object to_obj ON 
            ra.account_num = to_obj.account_num AND 
            ra.appraisal_yr = to_obj.appraisal_yr AND 
            ra.tax_obj_id = to_obj.tax_obj_id
        WHERE ra.account_num = %s
        """
        params = [account_num]
        if year:
            query += " AND ra.appraisal_yr = %s"
            params.append(year)
        query += " ORDER BY ra.appraisal_yr DESC, ra.tax_obj_id, ra.seq_num"
        
        self.cursor.execute(query, params)
        details['res_addl'] = self.cursor.fetchall()
        
        return details
    
    def export_account_data(self, account_num, year=None):
        """Export comprehensive account data as JSON"""
        print(f"🔍 Exporting data for account: {account_num}")
        if year:
            print(f"📅 Year filter: {year}")
        else:
            print("📅 All available years")
        
        # Check if account exists
        account_info = self.get_account_info(account_num, year)
        if not account_info:
            print(f"❌ No account found for account number: {account_num}")
            if year:
                print(f"   Try without year filter or check if data exists for {year}")
            return None
        
        print(f"✅ Found account data for {len(account_info)} year(s)")
        
        # Build comprehensive data structure
        data = {
            "account_number": account_num,
            "export_timestamp": datetime.now().isoformat(),
            "year_filter": year,
            "data": {
                # Primary table
                "account_info": [dict(row) for row in account_info],
                
                # Direct dependencies
                "account_apprl_year": [dict(row) for row in self.get_account_apprl_year(account_num, year)],
                "taxable_objects": [dict(row) for row in self.get_taxable_objects(account_num, year)],
                "land": [dict(row) for row in self.get_land_data(account_num, year)],
                "exemptions": {
                    table: [dict(row) for row in rows]
                    for table, rows in self.get_exemptions_data(account_num, year).items()
                },
                "other": {
                    table: [dict(row) for row in rows]
                    for table, rows in self.get_other_direct_dependencies(account_num, year).items()
                },
                
                # New tables (appraisal notices and protests)
                "appraisal_notices": [dict(row) for row in self.get_appraisal_notices(account_num, year)],
                "appraisal_review_board": [dict(row) for row in self.get_appraisal_review_board(account_num, year)],
                
                # Secondary dependencies
                "property_details": {
                    table: [dict(row) for row in rows]
                    for table, rows in self.get_property_details(account_num, year).items()
                }
            }
        }
        
        # Add summary statistics
        total_records = sum([
            len(data["data"]["account_info"]),
            len(data["data"]["account_apprl_year"]),
            len(data["data"]["taxable_objects"]),
            len(data["data"]["land"]),
            sum(len(rows) for rows in data["data"]["exemptions"].values()),
            sum(len(rows) for rows in data["data"]["other"].values()),
            len(data["data"]["appraisal_notices"]),
            len(data["data"]["appraisal_review_board"]),
            sum(len(rows) for rows in data["data"]["property_details"].values())
        ])
        
        data["summary"] = {
            "total_records": total_records,
            "years_available": sorted(list(set(
                row["appraisal_yr"] for row in account_info
            ))),
            "has_residential_details": len(data["data"]["property_details"]["res_detail"]) > 0,
            "has_commercial_details": len(data["data"]["property_details"]["com_detail"]) > 0,
            "has_additional_improvements": len(data["data"]["property_details"]["res_addl"]) > 0,
            "taxable_objects_count": len(data["data"]["taxable_objects"]),
            "land_parcels_count": len(data["data"]["land"]),
            "exemption_records": sum(len(rows) for rows in data["data"]["exemptions"].values()),
            "appraisal_notices_count": len(data["data"]["appraisal_notices"]),
            "has_protests": len(data["data"]["appraisal_review_board"]) > 0,
            "protest_records_count": len(data["data"]["appraisal_review_board"])
        }
        
        print(f"📊 Export summary:")
        print(f"   Total records: {total_records}")
        print(f"   Years available: {data['summary']['years_available']}")
        print(f"   Taxable objects: {data['summary']['taxable_objects_count']}")
        print(f"   Land parcels: {data['summary']['land_parcels_count']}")
        print(f"   Appraisal notices: {data['summary']['appraisal_notices_count']}")
        print(f"   Protest records: {data['summary']['protest_records_count']}")
        
        return data

def main():
    parser = argparse.ArgumentParser(description='Export comprehensive account data from DCAD database')
    parser.add_argument('--account-num', required=True, help='Account number to export')
    parser.add_argument('--year', type=int, help='Specific year to export (default: all years)')
    parser.add_argument('--all-years', action='store_true', help='Export all available years (default)')
    parser.add_argument('--output', help='Output JSON file (default: stdout)')
    parser.add_argument('--pretty', action='store_true', help='Pretty print JSON output')
    
    args = parser.parse_args()
    
    # Validate arguments
    if args.year and args.all_years:
        print("❌ Error: Cannot specify both --year and --all-years")
        sys.exit(1)
    
    exporter = AccountDataExporter()
    
    try:
        exporter.connect_to_database()
        
        # Export data
        year_filter = args.year if not args.all_years else None
        data = exporter.export_account_data(args.account_num, year_filter)
        
        if data is None:
            sys.exit(1)
        
        # Output JSON
        json_kwargs = {
            'cls': DecimalEncoder,
            'ensure_ascii': False
        }
        
        if args.pretty:
            json_kwargs['indent'] = 2
        
        json_output = json.dumps(data, **json_kwargs)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(json_output)
            print(f"✅ Data exported to: {args.output}")
        else:
            print("\n" + "="*50)
            print("JSON OUTPUT:")
            print("="*50)
            print(json_output)
        
    except KeyboardInterrupt:
        print("\n❌ Export cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error during export: {e}")
        sys.exit(1)
    finally:
        exporter.close_connection()

if __name__ == "__main__":
    main()