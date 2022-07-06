import os 
import shutil
import sys
import PyPDF2 as pdf

output = 'index.csv'
#  dir         = sys.argv[1]
dir         = 'Individual Files'
total_pages = 0
counter     = 0
out_dir     = r'.\Renamed Files'
if not os.path.exists(out_dir):
        os.makedirs(out_dir)

with open(output, 'w') as out:
    out.write('Date,Title,Page,File\n')

    for file in os.listdir(dir):
        # get date
        year  = file[0:4]
        month = file[5:7]
        day   = file[8:10]
        date  = month + '/' + day + '/' + year

        # get title
        title = os.path.splitext(file[11: ])[0]

        # get page number
        page_no   = total_pages + 1
        file_path = os.path.join(dir, file)
        with open(file_path, 'rb') as fp:
            pdf_file = pdf.PdfReader(fp)
            no_pages = pdf_file.getNumPages()
        total_pages =  total_pages + no_pages

        # rename files
        counter += 1
        out_file = 'ar_' + f"{counter:03d}" + '.pdf'
        out_path =  os.path.join(out_dir, out_file)
        shutil.copyfile(file_path, out_path)

        # write index row
        out_string = date + ',' + '"' + title + '"' + ',' + str(page_no) + ',' + out_file + '\n'
        out.write(out_string)
