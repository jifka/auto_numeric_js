# encoding: utf-8
require 'rubygems'
require 'haml'
require 'sinatra'
require "sinatra/reloader"

reload_n = 0

template :index do
<<-EOF
!!!
%html
	%head
		%script(type="text/javascript" src='jquery-1.4.3.js')
		%script(type="text/javascript" src='autoNumeric.\#{params['min'] ? 'min.' : ''}js?#{reload_n+=1}')
		:css
			#number {text-align: right}
			label {display: block}
			#log {font-size: 85%; line-height: 1em;}
			#log span {display: block}
		:javascript
			function log(str) {
				var spans = $('#log span');
				for(i=20; i<spans.length; i++){
					$(spans[i]).remove();
				}
				$('#log').prepend('<span>'+str+'</span>');
			}
	%body
		%form(method="post")
			- if params["min"]
				%input(type="hidden" name="min" value="\#{params['min']}")
			%p
				%label(for="meta") options for autoNumeric
				%textarea#meta(name="meta" cols=60 rows=4)&= meta
			%p
				%label(for="js") execute javascript
				%textarea#js(name="js" cols=60 rows=4)&= js
			%p
				%input#number(type="text" name="number" value=number)
			%button#apply apply
			%input(type="submit" value="reload")
		#log
			
		:javascript
			function applyMeta(){
				meta = $('#meta').val();
				meta = eval("("+meta+")");
				$('#log').html('');
				$('#number').autoNumeric(meta);
				eval($('#js').val());
			}
			$('#apply').click(function(){
				var $number = $('#number');
				var val = $number.val();
				var hnumber = $number.parent().html();
				$number.parent().html(hnumber);
				$('#number').val(val)
				applyMeta();
				return false;
			});
			applyMeta();
		-#end
EOF
end

default_params = { :meta => "{aSep: ' ', aForm: true, vMin: '-999999999.99'}", :number => 1000000, :js => '' }
get '/' do
  haml :index, :locals => default_params.merge(:params => params)
end

post '/' do
  locals = default_params
  params.each{|k, v| locals[k.to_sym] = v}
  locals[:params] = params
  haml :index, :locals => locals
end

