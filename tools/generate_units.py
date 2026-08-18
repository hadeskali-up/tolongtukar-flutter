import re
from pathlib import Path
src=Path(r'C:\Users\User\tolongtukar\composeApp\src\commonMain\kotlin\com\tolongtukar\app\converter\UnitDefinitions.kt').read_text(encoding='utf-8')
cut=src.index('// ── Lookup helpers')
src=src[:cut]
categories=[]
pos=0
while True:
    m=re.search(r'CategoryDef\("([^"]+)",\s*"([^"]+)"',src[pos:])
    if not m: break
    start=pos+m.start(); cid,name=m.group(1),m.group(2)
    i=src.find('(',start); depth=0; instr=False; esc=False; end=None
    for j in range(i,len(src)):
        c=src[j]
        if instr:
            if esc: esc=False
            elif c=='\\': esc=True
            elif c=='"': instr=False
        else:
            if c=='"': instr=True
            elif c=='(': depth+=1
            elif c==')':
                depth-=1
                if depth==0: end=j+1; break
    block=src[start:end]
    units=[]
    # General first three quoted args; strategy inferred from constructor name.
    for um in re.finditer(r'(factor|reciprocal|formula|UnitDef)\("([^"]+)",\s*"([^"]+)",\s*"((?:\\.|[^"])*)"',block):
        kind,uid,uname,symbol=um.groups()
        if any(u[0]==uid for u in units): continue
        symbol=symbol.replace('\\"','"').replace('\\\\','\\')
        factor='1.0'
        if kind in ('factor','reciprocal'):
            tail=block[um.end():]
            fm=re.match(r'\s*,\s*([^\)]+)\)',tail)
            if fm: factor=fm.group(1).strip().replace('PI','math.pi')
        units.append((uid,uname,symbol,kind,factor))
    categories.append((cid,name,units,'isStringBased = true' in block))
    pos=end
out=["import 'dart:math' as math;","import 'currency_rates.dart';",'',"enum UnitStrategy { factor, reciprocal, formula }",'''class UnitDef {
  const UnitDef({required this.id, required this.name, required this.symbol, required this.strategy, this.factor = 1});
  final String id, name, symbol;
  final UnitStrategy strategy;
  final double factor;
}''','''class CategoryDef {
  const CategoryDef({required this.id, required this.name, required this.units, this.isStringBased = false});
  final String id, name;
  final List<UnitDef> units;
  final bool isStringBased;
}''','class UnitDefinitions {','  static List<CategoryDef> get categories => [']
for cid,name,units,stringbased in categories:
    if cid=='currency': out.append("    CategoryDef(id: 'currency', name: 'Currency', units: CurrencyRates.units),"); continue
    out.append(f"    CategoryDef(id: {cid!r}, name: {name!r}, isStringBased: {str(stringbased).lower()}, units: [")
    for uid,uname,symbol,kind,factor in units:
        strategy={'factor':'factor','reciprocal':'reciprocal','formula':'formula','UnitDef':'formula'}[kind]
        out.append(f"      UnitDef(id: {uid!r}, name: {uname!r}, symbol: {symbol!r}, strategy: UnitStrategy.{strategy}, factor: {factor}),")
    out.append('    ]),')
out += ['  ];','  static CategoryDef? byId(String id) { for (final c in categories) { if (c.id == id) return c; } return null; }','}']
p=Path(__file__).parents[1]/'lib/domain/unit_definitions.dart';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(out)+'\n',encoding='utf-8')
print(f'generated {len(categories)} categories, {sum(len(x[2]) for x in categories)} units')
