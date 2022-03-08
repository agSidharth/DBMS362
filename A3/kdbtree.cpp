#include <bits/stdc++.h>
#include "file_manager.h"
#include "errors.h"
using namespace std;

int regionMaxNodes;
int pointMaxNodes;
int rootid;
map<int,int> nodeType;      // 2 for point nodes and 1 for region nodes...

void insertQuery(FileHandler& fh,FileManager& fm,vector<int>& qpoint,fstream& outfile)
{
    //first check if root points to null..
    if(rootid==-1)
    {
        PageHandler ph = fh.NewPage ();
	    char *data = ph.GetData ();

        int num = 0;                //root identifier
        memcpy (&data[0], &num, sizeof(int));

        num = 0;                    //split dimension
        memcpy (&data[4], &num, sizeof(int));

        fh.MarkDirty(0);
        fh.FlushPages();

        rootid = 0;
        nodeType[0] = 2;
        return;
    }

    int pointNode = pQuery(fh,fm,qpoint,outfile,false);

}

int pQuery(FileHandler& fh,FileManager& fm,vector<int>& qpoint,fstream& outfile,bool actualP)
{
    int curr_node = rootid;
    int parent_node = rootid;
    int regionsTouched = 0;

    while(nodeType[curr_node]==1)
    {
        parent_node = curr_node;
        PageHandler ph = fh.PageAt(curr_node);
        char *data = ph.GetData ();

        int split_dim,child,offset,node_num,valMIN,valMAX;
        memcpy(&split_dim, &data[4], sizeof(int));
        node_num = 0;
        offset = 8;

        while(node_num<regionMaxNodes)
        {
            memcpy(&child,&data[offset],sizeof(int));
            if(child==-1) break;

            memcpy(&valMIN,&data[offset+4*(1+split_dim)],sizeof(int));
            memcpy(&valMAX,&data[offset+4*(1+qpoint.size()+split_dim)],sizeof(int));
            memcpy(&curr_node,&data[offset],sizeof(int)); // curr_node cannot be lesser than this value..

            if(qpoint[split_dim]<valMAX && qpoint[split_dim]>=valMIN) break;
            //escape the loop if the curr_node is correct...

            offset += 4*(1+2*qpoint.size());
            node_num++;
        }
        fh.UnpinPage(parent_node);
        regionsTouched++;
    }

    if(!actualP) return curr_node;

    PageHandler ph = fh.PageAt(curr_node);
    char *data = ph.GetData ();
    bool test = false;
    int offset = 8;
    int num_nodes = 0;
    int temp,idx;

    while(num_nodes<pointMaxNodes)
    {
        for(idx=0;idx<qpoint.size();idx++)
        {
            memcpy(&temp,&data[offset+idx*4],sizeof(int));
            if(temp!=qpoint[idx]) break;
        }
        if(idx==qpoint.size()) {test = true;break;}

        offset += (qpoint.size()+1)*4;
        num_nodes++;
    }

    // now  based on test act accordingly..
    //correct this.. later..
    return test;
}

void rQuery(vector<int> qpoint,fstream& outfile)
{
    
}

int main(int argc, char* argv[])
{
    assert(argc>3);
    string input_file = argv[1];
    int dim = std::stoi(argv[2]);
    string output_file = argv[3];

    ifstream infile(input_file,ios::in);
    fstream outfile(output_file,ios::out);

    FileManager fm;
    FileHandler fh = fm.CreateFile("temp.txt");
    cout << "File created " << endl;

    regionMaxNodes = (PAGE_CONTENT_SIZE - 4)/((2*dim+1)*4);
    pointMaxNodes = (PAGE_CONTENT_SIZE - 4)/((dim+1)*4);
    rootid = -1;

    string line;
    while(getline(infile,line))
    {
        string word = "";
        string type = "";
        vector<int> qpoint;
        
        for(auto x:line)
        {
            if(x==' ')
            {
                if(type=="") type = word;
                else qpoint.push_back(stoi(word));
                word = "";
            }
            else word += x;
        }

        if(qpoint.size()>dim) {cout<<"ERROR IN INPUT FILE\n"; break;}
        else if(type=="INSERT") insertQuery(fh,fm,qpoint,outfile);
        else if(type=="PQUERY") pQuery(fh,fm,qpoint,outfile,true);
        else if(type=="RQUERY") rQuery(qpoint,outfile);
        else {cout<<"ERROR IN INPUT FILE\n"; break;}
    }
}