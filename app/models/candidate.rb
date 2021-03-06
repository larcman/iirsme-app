class Candidate < ApplicationRecord
  attr_accessor :current_user # For Audit purposes

  before_save :clear_other_occupation
  after_create :insert_log
  before_update :update_log
  before_destroy :delete_log

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :curp, presence: { message: "CURP no puede ir vacio" }
  validates :name, presence: { message: "Nombre no puede ir vacio" }
  validates :last_name1, presence: { message: "Al menos un Apellido debe de registrarse" }
  validates :birth_date, presence: { message: "Fecha de Nacimiento no puede ir vacio" }
  validates :evaluation_date, presence: { message: "Fecha de Evaluación no puede ir vacio" }
  validates :age, presence: { message: "Edad no puede ir vacio" }
  validates :phone, presence: { message: "Telefono no puede ir vacio" }
  validates :cell_phone, presence: { message: "Celular no puede ir vacio" }
  validates :email, presence: { message: "Email no puede ir vacio" }
  validates :email, format: { with: VALID_EMAIL_REGEX, message: "Email es invalido" },
                    unless: Proc.new { |f| f.email.blank? }
  validates :gender, presence: { message: "Sexo no puede ir vacio" }
  validates :marital_status, presence: { message: "Estado Civil no puede ir vacio" }
  validates :occupation, presence: { message: "Ocupación no puede ir vacio" }
  validates :occupation_other, if: :requires_occupation?, presence: { message: "Especifique otra ocupación" }
  validates :scolarship, presence: { message: "Escolaridad no puede ir vacio" }
  validates :birth_city, presence: { message: "Ciudad de Nacimiento no puede ir vacio" }
  validates :birth_state, presence: { message: "Estado de Nacimiento no puede ir vacio" }
  validates :birth_country, presence: { message: "País de Nacimiento no puede ir vacio" }
  validates :address_main_street, presence: { message: "Calle no puede ir vacio" }
  validates :address_street_no2, presence: { message: "No. Exterior no puede ir vacio" }
  validates :address_city, presence: { message: "Ciudad de Residencia no puede ir vacio" }
  validates :address_state, presence: { message: "Estado de Residencia no puede ir vacio" }
  validates :address_country, presence: { message: "País de Residencia no puede ir vacio" }
  validates :diagnosis_date, presence: { message: "Fecha de Diagnóstico no puede ir vacio" }
  validates :diagnosis, presence: { message: "Diagnóstico no puede ir vacio" }

  def insert_log
    log = []
    Audit.track_change(self.id, self.class.name.downcase, 'I', current_user.id, log.to_json)
  end

  def delete_log
    log = []
    Audit.track_change(self.id, self.class.name.downcase, 'D', current_user.id, log.to_json)
  end

  def update_log
    log = []
    Candidate.columns.each do |c|
      att = c.name
      if self.attribute_changed?(att) && att != 'updated_at'
        if Geoname.include?(att)
          old_value = Geoname.get_name(self.attribute_was(att))
          new_value = Geoname.get_name(self[att])
        else
          old_value = self.attribute_was(att)
          new_value = self[att]          
        end
        log << { :column => att, :old_value => old_value, :new_value => new_value }
      end
    end
    Audit.track_change(self.id, self.class.name.downcase, 'U', current_user.id, log.to_json)
  end

  def get_seqno
    self.seq_no.to_i
  end

  def get_last_name
    lastname = self.last_name1 + ' ' + self.last_name2 unless self.last_name2.blank?
  end

  def requires_occupation?
    occupation == 'Otro'
  end
  
  protected
  def clear_other_occupation
    self.occupation_other = nil if occupation != 'Otro'
  end

end