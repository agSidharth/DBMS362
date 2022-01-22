#!/usr/bin/env python3

"""
This scripts checks only for format of the query.sql file.
Individual sql queries are not evaluated here. 
Please use "evaluate" option on moodle if you need to test individual sql query format.
"""


import sys
import os
import re

TOTAL_QUESTIONS = 20

def err(*msg):
    print(*msg)
    exit(1)

def main(file):

    with open(file) as f:
        fcontents = f.read().strip()

    flines = list(map(lambda l: l.strip(), fcontents.split("\n")))
    


    # int -> string
    parts = {}
    
    part = ""
    data= ""

    # Build parts dict
    for index_of_line_in_file in range(0, len(flines), 1):

        l = flines[index_of_line_in_file]
        m = re.match(r"--\s*(\d+|CLEANUP)\s*--", l)
        #print(l)
        if m:
            
            parts[part] = data#flines[index_of_line_in_file+1]
            part = m.group(1).lower()
            data= ""

        else:
            data+=l+"\n"

    # The last part is cleanup
    parts[part] = data
   # print("parts ", parts)
    del parts['']
    
    print("  Query ids found ", list(parts.keys()))

    # Dump parts dict into individual files
    valid_parts = list(map(str, range(1, TOTAL_QUESTIONS + 1)))
    # valid_parts += ["preamble", "cleanup"]
    
    #print(valid_parts)

    for part in valid_parts:

        if part not in parts:
            err(
                "Error: Section not present: %s\n"
                "Make sure you create sections for each question, even if you leave them empty. Put an empty query if you wish to not attempt that query " % part.upper()
            )

        if part in ["preamble", "cleanup"]:
            fn = part + ".sql"
        else:
            fn = "part-%s.sql" % part

        # Write to separate file
        with open(fn, "w") as f:
            f.write(parts[part])

        # Remove this part from dict
        parts.pop(part)

    # Nothing should remain at this point
    if parts:
        err(
            "Error:  Extra sections present: %s \n" 
            "Remove them." % ",".join(parts.keys())
        )
        
        

    


if __name__ == "__main__":
    main(sys.argv[1])


    