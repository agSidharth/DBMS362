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

        int offset = 8;
        for(int idx=0;idx<qpoint.size();idx++)
        {
            memcpy(&data[offset],&qpoint[idx],sizeof(int));
            offset += 4;
        }

        num = -1;                   //location currently stores if the next element is present or not..
        memcpy(&data[offset],&num,sizeof(int));

        fh.MarkDirty(0);
        fh.FlushPages();

        rootid = 0;
        nodeType[0] = 2;
        return;
    }

    int pointNode = pQuery(fh,fm,qpoint,outfile,false);
    PageHandler ph = fh.PageAt(pointNode);
    char *data = ph.GetData ();
    
    int num,idx,offset;
    idx = 0;
    offset = 8;
    
    while(idx<pointMaxNodes-1)
    {
        memcpy(&num,&data[offset+qpoint.size()*4],4);
        if(num<-1) break;
        offset += (qpoint.size() + 1)*4;
        idx++;
    }

    // no overflow..
    if(num==-1)
    {
        offset += (qpoint.size() + 1)*4;
        num = pointNode;                        // what is stored in location by default..
        memcpy(&data[offset-4],&num,4);
        
        for(idx=0;idx<qpoint.size();idx++)
        {
            num = qpoint[idx];
            memcpy(&data[offset],&num,4);
            offset += 4;
        }

        num = -1;
        memcpy(&data[offset],&num,4);          // again -1 inserted in the end.

        return ;
    }
    fh.FlushPages();                            // need to confirm this..

    vector<int> tempVec;
    Reorganization(fh,fm,qpoint,pointNode,true,tempVec);
}

void Reorganization(FileHandler& fh,FileManager& fm,vector<int>& qpoint,int pointNode,bool isPoint,vector<int>& region)
{
    PageHandler ph = fh.PageAt(pointNode);
    char *data = ph.GetData ();

    int split_dim,offset,num;
    memcpy(&split_dim,&data[4],4);

    //Choose split element..
    vector<int> vecMedian;
    offset = 8;
    if(isPoint)
    {
        for(int idx=0;idx<pointMaxNodes;idx++)
        {
            memcpy(&num,&data[offset+4*split_dim],4);
            offset += 4*(qpoint.size()+1);
            vecMedian.push_back(num);
        }
        vecMedian.push_back(qpoint[split_dim]);
    }
    else
    {
        for(int idx = 0;idx<regionMaxNodes;idx++)
        {
            memcpy(&num,&data[offset+4*(1+split_dim)],4);
            offset += 4*(2*qpoint.size()+1);
            vecMedian.push_back(num);
        }
        vecMedian.push_back(region[4*(1+split_dim)]);
    }

    nth_element(vecMedian.begin(),vecMedian.begin()+vecMedian.size()/2,vecMedian.end());
    int split_element = vecMedian[vecMedian.size()/2];
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

vector<vector<int>> rQuery(FileHandler& fh,FileManager& fm,vector<int>& qpoint,fstream& outfile)
{
    // note here qpoint contains 2*dim...
    vector<vector<int>> pointsList;
    if(rootid==-1) return pointsList;
    int regTouched = 0;
    //for pointTouched use the size of pointsList..

    queue<int> toExplore;
    toExplore.push(rootid);

    while(toExplore.size()>0)
    {
        int curr_node = toExplore.front();
        toExplore.pop();

        PageHandler ph = fh.NewPage();
	    char *data = ph.GetData ();
        int offset,num,idx;
        offset = 8;
        idx = 0;

        // the node is a point node..
        if(nodeType[curr_node]==2)
        {
            vector<int> thisPoint;
            while(true)
            {
                memcpy(&num,&data[offset+4*idx],4);
                thisPoint.push_back(num);
                idx++;

                if(idx==qpoint.size()/2)            //qpoint.size() =  2*dim
                {
                    pointsList.push_back(thisPoint);
                    thisPoint.resize(0);

                    offset += 4*(idx+1);
                    idx = 0;

                    memcpy(&num,&data[offset-4],4);
                    if(num==-1) break;             //the last one will be having -1 
                }
            }
            continue;                   // no need to move forward..
        }

        while(idx<regionMaxNodes)
        {
            memcpy(&num,&data[offset],4);
            if(num==-1) break;
            //check if range overlaps.. then insert in the queue..
            //ask how to check what it means to overlap..
            idx++;
        }        
    }

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

        if((qpoint.size()!=dim && type!="RQUERY") && (qpoint.size()!=2*dim && type=="RQUERY")){cout<<"ERROR IN INPUT FILE\n"; break;}
        else if(type=="INSERT") insertQuery(fh,fm,qpoint,outfile);
        else if(type=="PQUERY") pQuery(fh,fm,qpoint,outfile,true);
        else if(type=="RQUERY") rQuery(fh,fm,qpoint,outfile);
        else {cout<<"ERROR IN INPUT FILE\n"; break;}
    }
}