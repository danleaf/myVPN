#include <stdio.h>
#include <list>
#include <map>
#include <iostream>
using namespace std;

struct P
{
	int g;
	int idx;

	P()
	{
		g = -1;
		idx = -1;
	}

	P(int ig, int iidx)
	{
		g = ig;
		idx = iidx;
	}

	bool operator <(const P& other) const
	{
		if (idx < 100 || other.idx < 100)
			return idx < other.idx;

		if (idx != other.idx)
			return idx < other.idx;

		return g < other.g;
	}

	bool operator <(const P& other)
	{
		return idx < other.idx;
	}

	void Print()
	{
		if (idx < 100)
			cout << "R" << idx << "_" << g;
		else
			cout << "d" << g;
	}
};

struct Assign
{
	P left;
	list<P> right;

	Assign()
	{

	}

	Assign(const P& pleft, const P& pright)
	{
		left = pleft;
		right.push_back(pright);
	}

	Assign(const P& pleft, const P& pright1, const P& pright2)
	{
		left = pleft;
		right.push_back(pright1);
		right.push_back(pright2);
	}

	Assign(const P& pleft, const P& pright1, const P& pright2, const P& pright3)
	{
		left = pleft;
		right.push_back(pright1);
		right.push_back(pright2);
		right.push_back(pright3);
	}

	void Print()
	{
		left.Print();
		cout << " = ";

		int c = 0;
		for (list<P>::iterator it = right.begin();
			it != right.end(); ++it)
		{
			c++;
			it->Print();
			if (c < right.size())
				cout << " + ";
			else
				cout << endl;
		}
	}

	void Unit()
	{
		map<P, int> m;
		for (list<P>::iterator it = right.begin();
			it != right.end(); ++it)
		{
			if (m.find(*it) == m.end())
			{
				m[*it] = 1;
			}
			else
			{
				m[*it]++;
			}
		}

		right.clear();
		for (map<P, int>::iterator it = m.begin();
			it != m.end(); ++it)
		{
			if (it->second % 2 == 1)
				right.push_back(it->first);
		}
	}
};

map<P, Assign> pmap;

bool replace(const P& p, list<P>& subg)
{
	subg.clear();
	if (0 == p.g)
		return false;

	map<P, Assign>::iterator itFind = pmap.find(p);
	if (itFind == pmap.end())
		return false;

	Assign& assign = itFind->second;

	for (list<P>::iterator it = assign.right.begin();
		it != assign.right.end(); ++it)
	{
		P tmp = *it;
		list<P> tmpList;

		tmp.g = p.g - 1;

		bool ret = replace(tmp, tmpList);
		if (!ret)
		{
			subg.push_back(tmp);
		}
		else
		{
			for (list<P>::iterator it2 = tmpList.begin();
				it2 != tmpList.end(); ++it2)
			{
				subg.push_back(*it2);
			}
		}
	}

	return true;
}

int main2()
{
	//x32+x26+x23+x22+x16+x12+x11+x10+x8+x7+x5+x4+x2+x1+1

	pmap[P(1, 31)] = Assign(P(1, 31), P(0, 30));
	pmap[P(1, 30)] = Assign(P(1, 30), P(0, 29));
	pmap[P(1, 29)] = Assign(P(1, 29), P(0, 28));
	pmap[P(1, 28)] = Assign(P(1, 28), P(0, 27));
	pmap[P(1, 27)] = Assign(P(1, 27), P(0, 26));
	pmap[P(1, 26)] = Assign(P(1, 26), P(0, 25), P(0, 31), P(0, 100));
	pmap[P(1, 25)] = Assign(P(1, 25), P(0, 24));
	pmap[P(1, 24)] = Assign(P(1, 24), P(0, 23));
	pmap[P(1, 23)] = Assign(P(1, 23), P(0, 22), P(0, 31), P(0, 100));
	pmap[P(1, 22)] = Assign(P(1, 22), P(0, 21), P(0, 31), P(0, 100));
	pmap[P(1, 21)] = Assign(P(1, 21), P(0, 20));
	pmap[P(1, 20)] = Assign(P(1, 20), P(0, 19));
	pmap[P(1, 19)] = Assign(P(1, 19), P(0, 18));
	pmap[P(1, 18)] = Assign(P(1, 18), P(0, 17));
	pmap[P(1, 17)] = Assign(P(1, 17), P(0, 16));
	pmap[P(1, 16)] = Assign(P(1, 16), P(0, 15), P(0, 31), P(0, 100));
	pmap[P(1, 15)] = Assign(P(1, 15), P(0, 14));
	pmap[P(1, 14)] = Assign(P(1, 14), P(0, 13));
	pmap[P(1, 13)] = Assign(P(1, 13), P(0, 12));
	pmap[P(1, 12)] = Assign(P(1, 12), P(0, 11), P(0, 31), P(0, 100));
	pmap[P(1, 11)] = Assign(P(1, 11), P(0, 10), P(0, 31), P(0, 100));
	pmap[P(1, 10)] = Assign(P(1, 10), P(0, 9), P(0, 31), P(0, 100));
	pmap[P(1, 9)] = Assign(P(1, 9), P(0, 8));
	pmap[P(1, 8)] = Assign(P(1, 8), P(0, 7), P(0, 31), P(0, 100));
	pmap[P(1, 7)] = Assign(P(1, 7), P(0, 6), P(0, 31), P(0, 100));
	pmap[P(1, 6)] = Assign(P(1, 6), P(0, 5));
	pmap[P(1, 5)] = Assign(P(1, 5), P(0, 4), P(0, 31), P(0, 100));
	pmap[P(1, 4)] = Assign(P(1, 4), P(0, 3), P(0, 31), P(0, 100));
	pmap[P(1, 3)] = Assign(P(1, 3), P(0, 2));
	pmap[P(1, 2)] = Assign(P(1, 2), P(0, 1), P(0, 31), P(0, 100));
	pmap[P(1, 1)] = Assign(P(1, 1), P(0, 0), P(0, 31), P(0, 100));
	pmap[P(1, 0)] = Assign(P(1, 0), P(0, 31), P(0, 100));

	Assign assign;

	assign.left = P(8, 31);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 30);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 29);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 28);
	replace(assign.left, assign.right);
	assign.Print();

	assign.left = P(8, 27);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 26);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 25);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 24);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 23);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 22);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 21);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 20);
	replace(assign.left, assign.right);
	assign.Print();

	assign.left = P(8, 19);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 18);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 17);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 16);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 15);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 14);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 13);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 12);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 11);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 10);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 9);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 8);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 7);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 6);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 5);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 4);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 3);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 2);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 1);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();

	assign.left = P(8, 0);
	replace(assign.left, assign.right);
	assign.Unit();
	assign.Print();



	int a;
	scanf_s("%d", &a);
	return 0;
}