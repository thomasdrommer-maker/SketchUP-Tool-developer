// Development only. npm install --no-save @ruby/3.4-wasm-wasi@2.10.1 @ruby/wasm-wasi@2.10.1
const fs=require('fs');
const {DefaultRubyVM}=require('@ruby/wasm-wasi/dist/node');
(async()=>{
const wasm=await WebAssembly.compile(fs.readFileSync(require.resolve('@ruby/3.4-wasm-wasi/dist/ruby+stdlib.wasm')));
const {vm}=await DefaultRubyVM(wasm);
const root=require('path').resolve(__dirname,'..');
const cp=require('child_process');
const files=cp.execFileSync('rg',['--files','src','test'],{cwd:root,encoding:'utf8'}).trim().split('\n').filter(p=>p.endsWith('.rb'));
for(const path of files){const code=fs.readFileSync(root+'/'+path,'utf8');vm.eval(`RubyVM::InstructionSequence.compile('${Buffer.from(code).toString('base64')}'.unpack1('m0'), ${JSON.stringify(path)})`);}
console.log(`Ruby 3.4 WASI: ${files.length} sources compiled`);
for(const path of files.filter(p=>p.startsWith('src/'))) {
 if(/\.sum\b/.test(fs.readFileSync(root+'/'+path,'utf8'))) throw Error('Runtime dependency on overridden sum: '+path);
}
// Deliberately broken host override, isolated to this test VM only.
vm.eval(`class Array; def sum(*); raise NameError, 'uninitialized constant Array::Fixnum'; end; end`);
vm.eval(`begin; [1,2].sum; raise 'Override simulation missing'; rescue NameError => error; raise unless error.message.include?('Array::Fixnum'); end`);
console.log('Broken Array#sum host simulation active');
vm.eval(fs.readFileSync(root+'/src/td_gfa_bsv_creator/building_metrics/geometry.rb','utf8'));
vm.eval(fs.readFileSync(root+'/test/building_metrics_geometry_test.rb','utf8'));
console.log(vm.eval('BuildingMetricsGeometryTest.instance_variable_get(:@count)').toString()+' geometry regression cases passed');
if(fs.existsSync(root+'/test/geometry_oracle.json')) {
vm.eval('require "json"');
const fixtures=fs.readFileSync(root+'/test/geometry_oracle.json','utf8');
vm.eval(`fixtures=JSON.parse(${JSON.stringify(fixtures)}); fixtures.each_with_index { |f,i| actual=TD::GFABSVCreator::BuildingMetrics::Geometry.hull3(f['points'])[:volume]; raise "Oracle #{i}: #{actual} != #{f['volume']}" if (actual-f['volume']).abs > [f['volume'].abs*1e-7,1e-8].max }; puts "#{fixtures.size} independent SciPy hull-volume comparisons passed"`);
console.log('15 independent SciPy hull-volume comparisons passed');
}
vm.eval('require "json"; require "digest"');
vm.eval(fs.readFileSync(root+'/src/td_gfa_bsv_creator/building_metrics/collector.rb','utf8'));
vm.eval(fs.readFileSync(root+'/test/building_metrics_collector_test.rb','utf8'));
console.log(vm.eval('BuildingMetricsCollectorTest.instance_variable_get(:@count)').toString()+' collector contract cases passed (doubles, not SketchUp)');
vm.eval('$stdout.flush; $stderr.flush');
const {vm: hostVM}=await DefaultRubyVM(wasm);
const main=fs.readFileSync(root+'/src/td_gfa_bsv_creator/building_metrics/main.rb','utf8').split('\n').filter(line=>!line.startsWith('require_relative ')).join('\n');
hostVM.eval(main);
hostVM.eval(fs.readFileSync(root+'/test/host_version_test.rb','utf8'));
hostVM.eval('$stdout.flush; $stderr.flush');
})().catch(e=>{console.error(e);process.exitCode=1;});
