'use strict';
const $ = id => document.getElementById(id);
let rows = [];
const format = value => value.toLocaleString('de-DE',{minimumFractionDigits:2,maximumFractionDigits:2});
function status(message){$('status').textContent=message;}
function preview_valid(valid){$('create').disabled=!valid;}
function dirty(){preview_valid(false);$('result').textContent='';}
function visibility(){
  const kind=$('kind').value, method=$('method').value;
  if(kind==='GFA' && method==='hull3')$('method').value='prism';
  const current=$('method').value;
  $('method').querySelector('[value=hull3]').disabled=kind==='GFA';
  $('contour_section').hidden=current!=='prism';
  $('angle').disabled=current!=='box';
  $('lower').disabled=current==='hull3';
  $('upper').disabled=kind==='GFA'||current==='hull3';
  $('method_hint').textContent=current==='hull3'?'Straffe konvexe 3D-Hülle aus den äußersten Geometriepunkten. Rücksprünge, Innenhöfe und Zwischenräume werden überbrückt.':current==='box'?'Umschließendes Rechteck nach eingestellter Ausrichtung; für BSV zwischen Unter- und Oberkante geschlossen.':'Automatischer Startvorschlag: konvexe Grundrisskontur. Rücksprünge durch Bearbeiten der Eckpunkte festlegen. Für BSV wird die Kontur senkrecht extrudiert.';
  dirty();
}
function loaded(data){
  $('lower').value=data.lower.toFixed(9);$('upper').value=data.upper.toFixed(9);
  $('contour').value=data.contour.map(p=>p.map(v=>v.toFixed(9)).join(' ; ')).join('\n');
  $('selection').textContent=`${data.objects} ausgewählte Objekte · ${data.points} Geometriepunkte · ${data.hidden} nicht sichtbare Teilobjekte ausgelassen · ${data.elapsed} ms`;
  status(data.contour_count>300?'Auswahl übernommen. Automatische Kontur hat mehr als 300 Punkte; Quader/3D-Hülle verwenden oder eine eigene Kontur mit höchstens 300 Punkten eingeben.':'Auswahl übernommen. Begrenzung und Messmethode prüfen.');dirty();
}
function payload(){return JSON.stringify({kind:$('kind').value,method:$('method').value,building:$('building').value,level:$('level').value,lower:$('lower').value,upper:$('upper').value,angle:$('angle').value,contour:$('contour').value.trim().split(/\n/).filter(x=>x.trim()).map(line=>line.split(';').map(x=>x.trim()))});}
function preview_result(data){$('result').textContent=`${format(data.value)} ${data.unit}`;status(`Vorschau: ${data.faces} Dreiecksflächen. Umhüllung im Modell prüfen; „Messobjekt erstellen“ übernimmt sie.`);preview_valid(true);}
function render_rows(data){rows=data;filter_rows();}
function filter_rows(){
  $('rows').replaceChildren();const query=$('filter').value.toLocaleLowerCase('de');
  rows.filter(r=>[r.name,r.building,r.level,r.kind].join(' ').toLocaleLowerCase('de').includes(query)).forEach(row=>{
    const tr=document.createElement('tr');tr.tabIndex=0;
    [row.name,row.building,row.level,row.value===null?'—':`${format(row.value)} ${row.unit}`,row.status].forEach(text=>{const td=document.createElement('td');td.textContent=text;tr.append(td);});
    const select=()=>sketchup.select(row.id);tr.addEventListener('click',select);tr.addEventListener('keydown',event=>{if(event.key==='Enter')select();});$('rows').append(tr);
  });
}
['kind','method'].forEach(id=>$(id).addEventListener('change',visibility));
['building','level','lower','upper','angle','contour'].forEach(id=>$(id).addEventListener('input',dirty));
$('filter').addEventListener('input',filter_rows);
['scan','list','export'].forEach(action=>$(action).addEventListener('click',()=>sketchup[action]()));
['preview','create'].forEach(action=>$(action).addEventListener('click',()=>{dirty();status(action==='preview'?'Geometrie wird geprüft und berechnet …':'Messobjekt wird erstellt …');sketchup[action](payload());}));
visibility();sketchup.ready();
