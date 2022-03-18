#include <bits/stdc++.h>
#include "file_manager.h"
#include "errors.h"
using namespace std;

int regionMaxNodes;
int pointMaxNodes;
int rootid;
int newnodeid;

vector<int> parentVec;
vector<int> splitVec;
int dim;

int pQuery(FileHandler& fh,FileManager& fm,vector<int>& qpoint,fstream& outfile,bool actualP)
{
    int curr_node = rootid;
    int parent_node = rootid;
    int regionsTouched = 0;
    bool pprint = false;

    while(true)
    {
        parent_node = curr_node;
        
        PageHandler ph = fh.PageAt(curr_node);
        char *data = ph.GetData ();

        int split_dim,child,offset,node_num,valMIN,valMAX,Ntype;
        memcpy(&Ntype,&data[8],4);
        
        if(Ntype==2) break;                             //Ntype=1 for region and 2 for point node.

        regionsTouched++;
        if(pprint)cerr<<"PQuery ,Curr_node: "<<curr_node<<", Ntype: "<<Ntype<<endl;
        parentVec.push_back(parent_node);
        memcpy(&split_dim, &data[4], 4);
        splitVec.push_back(split_dim);

        node_num = 0;
        offset = 12;
        
        if(pprint)cerr<<"Children: ";
        while(node_num<regionMaxNodes)
        {
            memcpy(&child,&data[offset],4);
            if(pprint)cerr<<child<<" ";
            if(child==-1) break;

            memcpy(&valMIN,&data[offset+4*(1+split_dim)],4);
            memcpy(&valMAX,&data[offset+4*(1+qpoint.size()+split_dim)],4);
            memcpy(&curr_node,&data[offset],4);         // curr_node cannot be lesser than this value..

            if(qpoint[split_dim]<valMAX && qpoint[split_dim]>=valMIN) break;
            //escape the loop if the curr_node is correct...

            offset += 4*(1+2*qpoint.size());
            node_num++;
        }
        if(pprint)cerr<<"\n";
        fh.MarkDirty(parent_node);
        fh.UnpinPage(parent_node);              
    }
    fh.MarkDirty(curr_node);

    if(!actualP) return curr_node;              // Is it real pQuery... if not return..

    parentVec.resize(0);
    splitVec.resize(0);

    fh.MarkDirty(curr_node);
    fh.UnpinPage(curr_node);
    PageHandler ph = fh.PageAt(curr_node);
    char *data = ph.GetData ();
    bool test = false;
    int offset = 12;
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

    fh.UnpinPage(curr_node);

    string sprint;
    if(test) sprint = to_string(regionsTouched) +"\nTRUE\n\n";
    else sprint = "0\nFALSE\n\n";
    outfile.write(sprint.data(),sprint.size());
    
    fh.FlushPages();           
    return test;
}

int returnMedian(vector<int>& a)
{
    int n = a.size();
    if(n%2==0)
    {
        nth_element(a.begin(),a.begin()+n/2,a.end());
        nth_element(a.begin(),a.begin()+(n-1)/2,a.end());

        if((a[(n-1)/2]+a[n/2])%2==0) return (a[(n-1)/2]+a[n/2])/2;
        return int((a[(n-1)/2]+a[n/2])/2) + 1;    
    }
    nth_element(a.begin(),a.begin()+n/2,a.end());
    return a[n/2];
}

void NodeSplit(PageHandler& left,PageHandler& right,FileHandler& fh,FileManager& fm,int thisNode,bool isPoint,int split_element,vector<int>& qpoint,int leftId,int rightId,bool addlast,int split_dim)
{
    PageHandler ph = fh.PageAt(thisNode);
    char *data = ph.GetData();
    char *Ldata = left.GetData();
    char *Rdata = right.GetData();

    fh.MarkDirty(leftId);
    fh.MarkDirty(rightId);

    int offset,num,this_split_dim,Loffset,Roffset,Ntype;
    memcpy(&this_split_dim,&data[4],4);
    memcpy(&Ntype,&data[8],4);

    memcpy(&Ldata[0],&leftId,4);
    memcpy(&Ldata[4],&this_split_dim,4);

    memcpy(&Rdata[0],&rightId,4);
    memcpy(&Rdata[4],&this_split_dim,4);

    offset = 12;
    Loffset = 12;
    Roffset = 12;

    isPoint = (Ntype==2);
    if(isPoint)
    {
        num = 2;
        memcpy(&Ldata[Loffset-4],&num,4);
        memcpy(&Rdata[Roffset-4],&num,4);
        
        //fm.PrintBuffer();
        cerr<<"NodeSplit: ";
        for(int idx=0;idx<pointMaxNodes;idx++)
        {
            cerr<<"("<<Loffset<<","<<Roffset<<") ";
            memcpy(&num,&data[offset+4*split_dim],4);
            if(num<split_element)
            {
                memcpy(&Ldata[Loffset],&data[offset],4*(dim+1));
                Loffset += 4*(dim+1);
            }
            else
            {
                memcpy(&Rdata[Roffset],&data[offset],4*(dim+1));
                Roffset += 4*(dim+1);
            }
            offset += 4*(dim+1);

            int checker;
            memcpy(&checker,&data[offset-4],4);
            if(checker<=-1) break;
        }
        cerr<<endl;
        //cerr<<Loffset<<"-:-"<<Roffset<<endl;
        //cerr<<"Offset: "<<offset<<"\n";

        //fm.PrintBuffer();
        num = -1;
        int temp_num = 0;
        int dumm_num = -2;
        if(qpoint[split_dim]<split_element && addlast)
        {
            if(Loffset>12) memcpy(&Ldata[Loffset-4],&temp_num,4); 
            memcpy(&Ldata[Loffset],&qpoint[0],4*(dim));
            Loffset += 4*(dim) + 4;
        }
        else if(addlast)
        {
            if(Roffset>12) memcpy(&Rdata[Roffset-4],&temp_num,4);
            memcpy(&Rdata[Roffset],&qpoint[0],4*(dim));
            Roffset += 4*(dim)+4;
        }
        
        if(Loffset>12)memcpy(&Ldata[Loffset-4],&num,4);       // to ensure last one is -1..
        else memcpy(&Ldata[Loffset+4*dim],&dumm_num,4);

        if(Roffset>12)memcpy(&Rdata[Roffset-4],&num,4);
        else memcpy(&Rdata[Roffset+4*dim],&dumm_num,4);

        cerr<<"break8, leftId:"<<leftId<<", rightId: "<<rightId<<", nodeId: "<<thisNode<<endl;

        fh.MarkDirty(leftId);
        fh.MarkDirty(rightId);
        fh.UnpinPage(leftId);
        fh.UnpinPage(rightId);

        fh.FlushPage(leftId);               
        fh.FlushPage(rightId);
        
        fh.MarkDirty(thisNode);
        fh.UnpinPage(thisNode);
        fh.FlushPage(thisNode);
        //cerr<<"break8 completed\n";
        return;                                 // since everything has been completed..
    }

    //if this is region node.
    // here qpoint will be the region node...region node will be of size 2*dim + 1
    num = 1;
    memcpy(&Ldata[Loffset-4],&num,4);
    memcpy(&Rdata[Roffset-4],&num,4);
    vector<int> region = qpoint;                // to avoid confusion...

    int leftnum,rightnum,temp;
    int dim = region.size()/2;
    cerr<<"break6: Parent splitting\n";
    cerr<<"leftId:"<<leftId<<",rightId:"<<rightId<<endl;
    fh.MarkDirty(leftId);
    fh.MarkDirty(rightId);

    for(int idx=0;idx<regionMaxNodes;idx++)
    {
        int checker;
        memcpy(&checker,&data[offset],4);
        if(checker<=-1) break;

        memcpy(&leftnum,&data[offset+4+4*split_dim],4);
        memcpy(&rightnum,&data[offset+4+4*dim+4*split_dim],4);

        if(split_element>=rightnum)
        {
            memcpy(&Ldata[Loffset],&data[offset],4*(region.size()));
            Loffset += 4*(region.size());
        }
        else if(split_element<leftnum)
        {
            memcpy(&Rdata[Roffset],&data[offset],4*(region.size()));
            Roffset += 4*(region.size());    
        }
        else
        {
            int nextToSplit;
            int leftChildId = newnodeid;
            int rightChildId = newnodeid + 1;
            newnodeid += 2;

            memcpy(&nextToSplit,&data[offset],4);       
            
            cerr<<"break9.1: Region node recursive splitting\n";

            PageHandler leftChild = fh.NewPage();    
            PageHandler rightChild = fh.NewPage();
            
            fh.MarkDirty(leftChildId);
            fh.MarkDirty(rightChildId);

            NodeSplit(leftChild,rightChild,fh,fm,nextToSplit,false,split_element,region,leftChildId,rightChildId,false,split_dim);

            fh.MarkDirty(leftChildId);
            fh.MarkDirty(rightChildId);
            fh.UnpinPage(leftChildId);
            fh.UnpinPage(rightChildId);

            memcpy(&Ldata[Loffset],&data[offset],4*(region.size()));
            memcpy(&Ldata[Loffset],&leftChildId,4);
            //memcpy(&Ldata[Loffset + 4*(1+split_dim)],&split_element,4);
            memcpy(&Ldata[Loffset + 4*(1+dim+split_dim)],&split_element,4);

            memcpy(&Rdata[Roffset],&data[offset],4*(region.size()));
            memcpy(&Rdata[Roffset],&rightChildId,4);
            memcpy(&Rdata[Roffset + 4*(1+split_dim)],&split_element,4);
            //memcpy(&Rdata[Roffset + 4*(1+dim+split_dim)],&split_element,4);

            Loffset += 4*(region.size());
            Roffset += 4*(region.size()); 
        }
        offset += 4*(region.size());
    }
    if(addlast)
    {
        memcpy(&leftnum,&region[1+split_dim],4);
        memcpy(&rightnum,&region[1+dim+split_dim],4);
        cerr<<"Here in region addlast\n";

        if(split_element>=rightnum)
        {
            memcpy(&Ldata[Loffset],&region[0],4*(region.size()));
            Loffset += 4*(region.size());
        }
        else if(split_element<leftnum)
        {
            memcpy(&Rdata[Roffset],&region[0],4*(region.size()));
            Roffset += 4*(region.size());    
        }
        else
        {
            int nextToSplit;
            int leftChildId = newnodeid;
            int rightChildId = newnodeid + 1;
            newnodeid += 2;

            memcpy(&nextToSplit,&region[0],4);
            //cerr<<"nextToSplit: "<<nextToSplit<<endl;       

            PageHandler leftChild = fh.NewPage();
            PageHandler rightChild = fh.NewPage();
            //fm.PrintBuffer();
            fh.MarkDirty(leftChildId);
            fh.MarkDirty(rightChildId);

            NodeSplit(leftChild,rightChild,fh,fm,nextToSplit,false,split_element,region,leftChildId,rightChildId,false,split_dim);

            fh.MarkDirty(leftChildId);
            fh.MarkDirty(rightChildId);
            fh.UnpinPage(leftChildId);
            fh.UnpinPage(rightChildId);

            memcpy(&Ldata[Loffset],&region[0],4*(region.size()));
            memcpy(&Ldata[Loffset],&leftChildId,4);
            //memcpy(&Ldata[Loffset + 4*(1+split_dim)],&split_element,4);
            memcpy(&Ldata[Loffset + 4*(1+dim+split_dim)],&split_element,4);


            memcpy(&Rdata[Roffset],&region[0],4*(region.size()));
            memcpy(&Rdata[Roffset],&rightChildId,4);
            memcpy(&Rdata[Roffset + 4*(1+split_dim)],&split_element,4);
            //memcpy(&Rdata[Roffset + 4*(1+dim+split_dim)],&split_element,4); 

            Loffset += 4*(region.size());
            Roffset += 4*(region.size());
        }    
    }
    
    temp = -1;
    if(Loffset<PAGE_SIZE) memcpy(&Ldata[Loffset],&temp,4);
    if(Roffset<PAGE_SIZE) memcpy(&Rdata[Roffset],&temp,4);
    
    fh.MarkDirty(leftId);
    fh.MarkDirty(rightId);

    fh.UnpinPage(leftId);
    fh.UnpinPage(rightId);

    fh.FlushPage(leftId);
    fh.FlushPage(rightId);

    fh.MarkDirty(thisNode);
    fh.UnpinPage(thisNode);
    fh.FlushPage(thisNode);
}

void Reorganization(FileHandler& fh,FileManager& fm,vector<int>& qpoint,int thisNode,bool isPoint,vector<int>& region)
{
    PageHandler ph = fh.PageAt(thisNode);
    char *data = ph.GetData ();
    bool createRoot = false;

    cerr<<"Entered Reorganization on "<<thisNode<<"\n";
    int split_dim,offset,num,parentNode;

    if(parentVec.size()>0)
    {
        //cerr<<"break4.1: "<<parentVec.size()<<endl;
        split_dim = splitVec[splitVec.size()-1];
        parentNode = parentVec[parentVec.size()-1];
        splitVec.pop_back();
        parentVec.pop_back();
    }
    else
    {
        memcpy(&split_dim,&data[4],4);
        split_dim = (split_dim-1)%(qpoint.size()); // as we go up we increase split_dim..
        createRoot = true;
    }

    //Choose split element..
    //cerr<<"break5: \n";
    vector<int> vecMedian;
    offset = 12;
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
        vecMedian.push_back(region[(1+split_dim)]);
    }

    int split_element = returnMedian(vecMedian);

    PageHandler left = fh.NewPage();
    int leftId = newnodeid;

    PageHandler right = fh.NewPage();
    int rightId = newnodeid + 1;
    newnodeid += 2;

    fh.MarkDirty(leftId);
    fh.MarkDirty(rightId);

    cerr<<"In reorgan: leftID :"<<leftId<<", rightID: "<<rightId<<endl;

    if(isPoint) NodeSplit(left,right,fh,fm,thisNode,isPoint,split_element,qpoint,leftId,rightId,true,split_dim);
    else NodeSplit(left,right,fh,fm,thisNode,isPoint,split_element,region,leftId,rightId,true,split_dim);

    fh.MarkDirty(leftId);
    fh.MarkDirty(rightId);

    fh.UnpinPage(leftId);
    fh.UnpinPage(rightId);

    /*/ Debugger.. Start
    
    int debug,debugoff;
    debugoff = 12;

    char* debugdata = left.GetData();
    memcpy(&debug,&debugdata[debugoff],4);
    cerr<<"DebugLeft1: "<<debug<<endl;

    debugdata = right.GetData();
    memcpy(&debug,&debugdata[debugoff],4);
    cerr<<"DebugRight1: "<<debug<<endl;

    // Debugger.. End*/

    vector<int> parentMin(qpoint.size());
    vector<int> parentMax(qpoint.size());

    char* pdata;
    PageHandler pph;
    if(createRoot)
    {
        rootid = newnodeid;
        newnodeid++;
        parentNode = rootid;
        pph = fh.NewPage();
        pdata = pph.GetData ();

        cerr<<"Create new root: "<<rootid<<endl;

        int temp2 = rootid;
        memcpy(&pdata[0],&temp2,4);
        temp2 = split_dim;
        memcpy(&pdata[4],&temp2,4);
        temp2 = 1;
        memcpy(&pdata[8],&temp2,4);

        memcpy(&pdata[12],&thisNode,4);

        temp2 = INT_MIN;
        for(int i=0;i<qpoint.size()*2;i++)
        {
            if(i>=qpoint.size()) temp2 = INT_MAX;
            memcpy(&pdata[16+i*4],&temp2,4);
        }
        temp2 = -1;
        memcpy(&pdata[12+4*(2*qpoint.size()+1)],&temp2,4);
        fh.MarkDirty(parentNode);
    }
    else
    {
        cerr<<"Reorgan ParentNode: "<<parentNode<<endl;
        pph = fh.PageAt(parentNode);
        pdata = pph.GetData ();
        fh.MarkDirty(parentNode);
    }
    
    bool poverflow = true;
    offset = 12;

    cerr<<"Current regions: ";
    for(int idx=0;idx<regionMaxNodes;idx++)
    {
        memcpy(&num,&pdata[offset],4);
        cerr<<num<<" ";
        if(num==thisNode)
        {
            memcpy(&parentMin[0],&pdata[offset+4],4*(qpoint.size()));
            memcpy(&parentMax[0],&pdata[offset+4+4*(qpoint.size())],4*qpoint.size());
            cerr<<"("<<leftId<<") ";

            memcpy(&pdata[offset],&leftId,4);
            memcpy(&pdata[offset+4*(1+qpoint.size()+split_dim)],&split_element,4);

            parentMin[split_dim] = split_element;       // for right node to be inserted ..
        }
        else if(num==-1)
        {
            poverflow = false;
            break;
        }
        offset += 4*(2*qpoint.size()+1);
    }
    cerr<<endl;

    if(!poverflow)
    {
        cerr<<"Child overflow: "<<thisNode<<endl;
        memcpy(&pdata[offset],&rightId,4);
        memcpy(&pdata[offset+4],&parentMin[0],4*(qpoint.size()));
        memcpy(&pdata[offset+4*(1+qpoint.size())],&parentMax[0],4*(qpoint.size()));

        int temp = -1;
        if(offset+4*(1+2*qpoint.size())<PAGE_SIZE) memcpy(&pdata[offset+4*(1+2*qpoint.size())],&temp,4);

        fh.MarkDirty(parentNode);
        fh.UnpinPage(parentNode);
        fh.FlushPage(parentNode);            
        return ;
    }

    cerr<<"break7: Parent Overflow..\n";
    vector<int> newRegion;
    newRegion.push_back(rightId);
    for(int idx=0;idx<qpoint.size();idx++) newRegion.push_back(parentMin[idx]);
    for(int idx=0;idx<qpoint.size();idx++) newRegion.push_back(parentMax[idx]);

    Reorganization(fh,fm,qpoint,parentNode,false,newRegion);

    cerr<<"100% comp. reorgan: \n";
    fh.MarkDirty(parentNode);
    fh.UnpinPage(parentNode);
    fh.FlushPage(parentNode);

    return;
}

void printInsertQuery(FileHandler& fh,FileManager& fm,vector<int>& qpoint,fstream& outfile)
{
    string sprint = "INSERTION DONE:\n";
    outfile.write(sprint.data(),sprint.size());

    int tempPoint = pQuery(fh,fm,qpoint,outfile,false);
    //cerr<<tempPoint<<endl;

    PageHandler temp_ph = fh.PageAt(tempPoint);
    char *temp_data = temp_ph.GetData ();

    fh.MarkDirty(tempPoint);

    int offset = 12;
    int temp_num,idx;
    idx = 0;
    string temp_str;

    vector<int> point_temp(dim);

    while(idx<pointMaxNodes)
    {
        memcpy(&temp_num,&temp_data[offset+4*dim],4);
        if(temp_num<=-2) break;

        memcpy(&point_temp[0],&temp_data[offset],4*dim);

        for(int jdx=0;jdx<dim;jdx++) 
        {
            temp_str = to_string(point_temp[jdx]) + " ";
            outfile.write(temp_str.data(),temp_str.size());
        }
        temp_str = "\n";
        outfile.write(temp_str.data(),temp_str.size());

        offset += 4*(dim+1);
        idx++;
        if(temp_num<=-1) break;
    }
    temp_str = "\n";
    outfile.write(temp_str.data(),temp_str.size());

    fh.FlushPages();
    return;
}

void insertQuery(FileHandler& fh,FileManager& fm,vector<int>& qpoint,fstream& outfile)
{
    //first check if root points to null..
    parentVec.resize(0);
    splitVec.resize(0);

    //cerr<<"Entered Insert\n";

    if(rootid==-1)
    {
        PageHandler ph = fh.NewPage();
	    char *data = ph.GetData ();

        int num = 0;                //root identifier
        memcpy(&data[0],&num,sizeof(int));

        num = 0;                    //split dimension
        memcpy(&data[4],&num,sizeof(int));

        num = 2;                    //this is pointNode.
        memcpy(&data[8],&num,4);

        int offset = 12;
        memcpy(&data[offset],&qpoint[0],4*(qpoint.size()));

        num = -1;                   //location currently stores if the next element is present or not..
        memcpy(&data[offset+4*(qpoint.size())],&num,sizeof(int));

        fh.MarkDirty(0);
        fh.UnpinPage(0);
        fh.FlushPage(0);

        rootid = newnodeid;
        newnodeid++;

        cerr<<"ROOT NODE CREATED"<<"\n";
        printInsertQuery(fh,fm,qpoint,outfile);

        return;
    }

    //cerr<<"break1\n";
    int pointNode = pQuery(fh,fm,qpoint,outfile,false);   // returns the pointNode where we can insert this point.
    cerr<<"searched: "<<pointNode<<"\n";

    PageHandler ph = fh.PageAt(pointNode);
    char *data = ph.GetData ();
    
    int num,idx,offset;
    idx = 0;
    offset = 12;
    
    //cerr<<"break2: "<<pointMaxNodes<<endl;
    while(idx<pointMaxNodes-1)
    {
        memcpy(&num,&data[offset+qpoint.size()*4],4);
        if(num<=-1) break;                                // last location has -1.
        offset += (qpoint.size() + 1)*4;
        idx++;
    }

    // no overflow..
    if(num<=-1)
    {
        //cerr<<"break3: "<<offset<<endl;
        if(num==-1)
        {
            offset += (qpoint.size() + 1)*4;
            num = pointNode; 
            memcpy(&data[offset-4],&num,4);
        }
        
        memcpy(&data[offset],&qpoint[0],4*(qpoint.size()));
        num = -1;
        memcpy(&data[offset+4*(qpoint.size())],&num,4);          // again -1 inserted in the end.
    }
    else
    {
        //cerr<<"Point node overflow..\n";
        vector<int> tempVec;                        // just to maintain same arguments..
        Reorganization(fh,fm,qpoint,pointNode,true,tempVec);
    }

    fh.MarkDirty(pointNode);              
    fh.UnpinPage(pointNode);
    fh.FlushPages();

    parentVec.resize(0);
    splitVec.resize(0);

    // Now printing the points of the point Node..
    printInsertQuery(fh,fm,qpoint,outfile);                   
}

void printRquery(vector<int>& point,int regTouched,fstream& outfile)
{
    string temp_str = "POINT: ";
    outfile.write(temp_str.data(),temp_str.size());

    for(int idx=0;idx<point.size();idx++)
    {
        temp_str = to_string(point[idx]) + " ";
        outfile.write(temp_str.data(),temp_str.size());
    }

    temp_str = "NUM REGION NODES TOUCHED: "+to_string(regTouched) + "\n";
    outfile.write(temp_str.data(),temp_str.size());

}

void rQuery(FileHandler& fh,FileManager& fm,vector<int>& qpoint,fstream& outfile)
{
    // note here qpoint contains 2*dim...
    cerr<<"Entered RQUERY\n";
    //vector<vector<int>> pointsList;
    if(rootid==-1) return ;
    int regTouched = 0;
    //for pointTouched use the size of pointsList..

    dim = qpoint.size()/2;
    queue<int> toExplore;
    toExplore.push(rootid);

    while(toExplore.size()>0)
    {
        //cerr<<"Rentered the queue\n";
        int curr_node = toExplore.front();
        toExplore.pop();

        PageHandler ph = fh.PageAt(curr_node);
	    char *data = ph.GetData ();

        int offset,num,idx,Ntype;
        memcpy(&Ntype,&data[8],4);
        
        offset = 12;
        idx = 0;

        cerr<<"RPQ: "<<curr_node<<", type = "<<Ntype<<endl;

        fh.MarkDirty(curr_node);
        fh.UnpinPage(curr_node);              
        
        if(Ntype==2)
        {
            vector<int> thisPoint(dim,0);
            int checker;
            offset = 12;

            for(int jdx=0;jdx<pointMaxNodes;jdx++)
            {
                memcpy(&checker,&data[offset+4*dim],4);
                cerr<<checker<<" ";
                if(checker<=-2) break;

                memcpy(&thisPoint[0],&data[offset],4*dim);

                printRquery(thisPoint,regTouched,outfile);
                if(checker<=-1) break;
                
                offset += 4*(dim+1);
            }
        }
        else
        {
            while(idx<regionMaxNodes)
            {
                regTouched++;
                memcpy(&num,&data[offset],4);        //num has child id..
                if(num==-1) break;
                
                int rmin,rmax;
                bool test = true;

                for(int jdx=0;jdx<dim;jdx++)
                {
                    memcpy(&rmin,&data[offset+4*(1+jdx)],4);
                    memcpy(&rmax,&data[offset+4*(1+dim+jdx)],4);

                    if(!(rmin<=qpoint[2*jdx] && rmax>qpoint[2*jdx+1])) {test = false;break;}
                }
                if(test) toExplore.push(num);

                offset += 4*(2*dim+1);        
                idx++;

                //cerr<<idx<<" ";
            }
        }        
        //cerr<<endl;
    }
    cerr<<"Finished REQUERY\n";

    string temp_str = "\n\n";
    outfile.write(temp_str.data(),temp_str.size());

    fh.FlushPages();
    return;
}

int main(int argc, char* argv[])
{
    assert(argc>3);
    string input_file = argv[1];
    dim = std::stoi(argv[2]);
    string output_file = argv[3];

    ifstream infile(input_file,ios::in);
    fstream outfile(output_file,ios::out);

    FileManager fm;
    FileHandler fh = fm.CreateFile("temp1234.txt");
    cerr << "File created " << endl;

    //4 for nodeid, 4 for split_dim, 4 for nodetype..
    regionMaxNodes = (PAGE_SIZE - 12)/((2*dim+1)*4);
    pointMaxNodes = (PAGE_SIZE - 12)/((dim+1)*4);
    rootid = -1;

    cerr<<"RegionMaxNodes: "<<regionMaxNodes<<endl;
    cerr<<"PointMaxNodes: "<<pointMaxNodes<<endl;

    string line;
    int linenum = 1;
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
        qpoint.push_back(stoi(word));

        cerr<<"line: "<<linenum<<"\n";
        //for(int jdx=0;jdx<qpoint.size();jdx++) cerr<<qpoint[jdx]<<" ";

        if((qpoint.size()!=dim && type!="RQUERY") && (qpoint.size()!=2*dim && type=="RQUERY")){cerr<<"ERROR IN INPUT FILE\n"; break;}
        else if(type=="INSERT") insertQuery(fh,fm,qpoint,outfile);
        else if(type=="PQUERY") pQuery(fh,fm,qpoint,outfile,true);
        else if(type=="RQUERY") rQuery(fh,fm,qpoint,outfile);
        else {cerr<<"ERROR IN INPUT FILE\n"; break;}
        
        //if(linenum==53) break;
        linenum++;
    }
}